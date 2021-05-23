// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/timeline_service.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class EditorBloc extends Bloc<EditorEvent, EditorState?> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  EditorBloc(
      {required GoogleDrive storage,
      required NavigationBloc navigationBloc,
      required FolderStorageBloc folderStorageBloc})
      : super(null) {
    _folderStorageBloc = folderStorageBloc;
    _storage = storage;
    _navigationBloc = navigationBloc;
  }

  late GoogleDrive _storage;
  late NavigationBloc _navigationBloc;
  late FolderStorageBloc _folderStorageBloc;
  late List<int> imageIndexesToIgnore;

  @override
  Stream<EditorState> mapEventToState(EditorEvent event) async* {
    switch (event.type) {
      case EditorType.createFolder:
        yield await _createFolder(event);
        break;
      case EditorType.deleteFolder:
        await _deleteFolder(event);
        break;
      case EditorType.uploadImages:
        await _uploadImages(event);
        break;
      case EditorType.ignoreImage:
        _ignoreImage(event);
        break;
      case EditorType.deleteImage:
        await _deleteImage(event);
        break;
      case EditorType.updateName:
        _updateName(event);
        break;
      case EditorType.updateTimestamp:
        await _updateTimestamp(event);
        break;
      case EditorType.updateImageMetadata:
        _updateImageMetadata(event);
        break;
      case EditorType.updateMetadata:
        _updateMetadata(event);
        break;
      case EditorType.updatePosition:
        _updatePosition(event);
        break;
      case EditorType.uploadStatus:
        yield _relayState(EditorType.uploadStatus, event);
        break;
      case EditorType.syncingState:
        yield _relayState(EditorType.syncingState, event);
        break;
    }
  }

  Future<EditorState> _createFolder(EditorEvent event) async {
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    Folder parent = event.data as Folder;
    final Folder? folder = await _storage.createFolder(parent);
    if (folder != null) {
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    } else {
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.error, refreshUI: event.refreshUI));
    }
    return EditorState(EditorType.createFolder, data: folder);
  }

  Future<void> _deleteFolder(EditorEvent event) async {
    Folder folder = event.data as Folder;
    String? error;
    await _storage.delete(folder.id!).then((dynamic value) {
      folder.parent!.subFolders!
          .removeWhere((subfolder) => subfolder.id == folder.id);
      _folderStorageBloc.add(FolderStorageEvent(FolderStorageType.refresh,
          folderID: folder.parent!.id));
      return null;
    }, onError: (_) {
      error = 'Error when deleting story';
    });

    if (error == null && event.closeDialog) {
      _navigationBloc.add(NavigatorPopDialogEvent());
    }
  }

  Future<void> _uploadImages(EditorEvent event) async {
    final UpdateImagesEvent update = event.data as UpdateImagesEvent;
    imageIndexesToIgnore = <int>[];
    final List<MapEntry<String, FolderMedia>> entries =
        update.images.entries.toList();
    final int length = entries.length;
    bool errors = false;
    for (int i = 0; i < length; i++) {
      final MapEntry<String, FolderMedia> entry = entries[i];
      try {
        await _uploadImage(i, entry.key, entry.value, update.folder);
      } catch (e) {
        errors = true;
        add(EditorEvent(EditorType.uploadStatus,
            folderID: update.folder.id,
            parentID: update.folder.parent!.id,
            data: MediaProgress(i, 0, 0),
            error: 'Could not upload'));
      }
    }

    _folderStorageBloc.add(const FolderStorageEvent(FolderStorageType.refresh));
    if (!errors) {
      _navigationBloc.add(NavigatorPopEvent());
      add(const EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: true));
    }
  }

  Future<void> _uploadImage(
    int index,
    String name,
    FolderMedia storyMedia,
    Folder folder,
  ) async {
    final StreamController<List<int>> streamController =
        StreamController<List<int>>();
    final int totalSize = storyMedia.contentSize ?? 100;
    int sent = 0;

    storyMedia.stream!.listen((List<int> event) {
      if (imageIndexesToIgnore.contains(index)) {
        streamController.addError('canceled');
      } else {
        sent += event.length;
        add(EditorEvent(EditorType.uploadStatus,
            folderID: folder.id,
            parentID: folder.parent!.id,
            data: MediaProgress(index, totalSize, sent)));
        streamController.add(event);
      }
    }, onDone: () {
      streamController.close();
    }, onError: (dynamic error) {
      streamController.close();
    });

    final String? imageID = await _storage.uploadMediaToFolder(
        folder.id!, name, storyMedia, streamController.stream);

    if (imageID != null) {
      final Folder? eventData =
          TimelineService.getFolderWithID(folder.id!, folder.parent);
      storyMedia.id = imageID;
      storyMedia.retrieveThumbnail = true;
      eventData!.images!.putIfAbsent(imageID, () => storyMedia);
      folder.images!.putIfAbsent(imageID, () => storyMedia);

      add(EditorEvent(EditorType.uploadStatus,
          folderID: folder.id,
          parentID: folder.parent!.id,
          data: MediaProgress(index, totalSize, sent)));
    } else {
      throw 'Error when creating image';
    }
  }

  void _ignoreImage(EditorEvent event) {
    imageIndexesToIgnore = <int>[];
    imageIndexesToIgnore.add(event.data as int);
  }

  Future<void> _deleteImage(EditorEvent event) async {
    UpdateDeleteImageEvent update = event.data as UpdateDeleteImageEvent;
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    final Folder eventData = TimelineService.getFolderWithID(
        update.folder.id!, update.folder.parent)!;
    final String? error = await _deleteFile(update.imageID);
    if (error == null) {
      eventData.images!.remove(update.imageID);
      update.folder.images!.remove(update.imageID);
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    } else {
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.error, refreshUI: event.refreshUI));
    }
  }

  Future<String?> _deleteFile(String fileID) async {
    try {
      _storage.delete(fileID);
      return null;
    } catch (e) {
      return 'could not delete $fileID';
    }
  }

  void _updateName(EditorEvent event) {
    final Folder folder = event.data as Folder;
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    String fileName = FolderNameData.toFileName(folder);
    _storage.updateFileName(folder.id!, fileName).then((value) {
      Folder eventData =
          TimelineService.getFolderWithID(folder.id!, folder.parent)!;
      eventData.emoji = folder.emoji;
      eventData.title = folder.title;
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    });
  }

  Future<void> _updateTimestamp(EditorEvent event) async {
    final Folder folder = event.data as Folder;
    final String folderID = folder.id!;
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    try {
      await _storage.updateMetadata(folderID, folder.metadata ?? {});
      final Folder? eventData =
          TimelineService.getFolderWithID(folderID, folder.parent);
      if (eventData != null) {
        eventData.setTimestamp(folder.getTimestamp());
      }
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    } catch (e) {
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.error, refreshUI: event.refreshUI));
    }
  }

  void _updateImageMetadata(EditorEvent event) {
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    final UpdateImageMetaDataEvent update =
        event.data as UpdateImageMetaDataEvent;

    _storage
        .updateMetadata(update.media.id, update.media.metadata ?? {})
        .then((value) {
      TimelineService.getFolderWithID(update.folder.id!, update.folder.parent)!
          .images!
          .update(update.media.id, (_) => update.media);
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    });
  }

  void _updateMetadata(EditorEvent event) {
    add(EditorEvent(EditorType.syncingState,
        data: SavingState.saving, refreshUI: event.refreshUI));
    final Folder folder = event.data as Folder;

    _storage.updateMetadata(folder.id!, folder.metadata ?? {}).then((value) {
      TimelineService.getFolderWithID(folder.id!, folder.parent)!.metadata =
          folder.metadata!;
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    });
  }

  void _updatePosition(EditorEvent event) {
    UpdatePosition uip = event.data as UpdatePosition;
    List<dynamic> images = uip.items;
    int currentIndex = uip.currentIndex;

    add(const EditorEvent(EditorType.syncingState, data: SavingState.saving));

    _storage.updatePosition(uip).then((newOrder) {
      final Folder? eventData = TimelineService.getFolderWithID(
          uip.folderID, _folderStorageBloc.rootFolder);

      if (eventData != null) {
        final FolderMedia? oldItem =
            eventData.images?[images[currentIndex].imageKey];
        if (oldItem != null) {
          oldItem.setTimestamp(newOrder);
        }
      }

      add(const EditorEvent(EditorType.syncingState,
          data: SavingState.success));
    });
  }

  EditorState _relayState(EditorType type, EditorEvent event) {
    return EditorState(type,
        folderID: event.folderID,
        parentID: event.parentID,
        refreshUI: event.refreshUI,
        data: event.data,
        error: event.error);
  }
}
