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
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/cloud_provider/storage_service.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class EditorBloc extends Bloc<EditorEvent, EditorState?> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  EditorBloc(
      {required StorageService storage,
      required NavigationBloc navigationBloc,
      required FolderStorageBloc folderStorageBloc})
      : super(null) {
    _folderStorageBloc = folderStorageBloc;
    _storage = storage;
    _navigationBloc = navigationBloc;
  }

  late StorageService _storage;
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
        _deleteFolder(event);
        break;
      case EditorType.uploadImages:
        _uploadImages(event);
        break;
      case EditorType.ignoreImage:
        _ignoreImage(event);
        break;
      case EditorType.deleteImage:
        _deleteImage(event);
        break;
      case EditorType.updateName:
        _updateName(event);
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
    final Folder parent = event.data as Folder;
    Folder? folder;
    await _syncData(event, () async {
      return _storage.createFolder(parent: parent);
    }, (Folder? newFolder) => folder = newFolder);
    return EditorState(EditorType.createFolder, data: folder);
  }

  Future<void> _deleteFolder(EditorEvent event) async {
    final Folder folder = event.data as Folder;
    await _storage.deleteResource(folder.id!).then((dynamic value) {
      folder.parent!.subFolders
          .removeWhere((Folder subfolder) => subfolder.id == folder.id);
      _folderStorageBloc.add(FolderStorageEvent(FolderStorageType.refresh,
          folderID: folder.parent!.id));
      _navigationBloc.add(NavigatorPopDialogEvent());
    });
  }

  Future<void> _uploadImages(EditorEvent event) async {
    final UpdateImagesEvent update = event.data as UpdateImagesEvent;
    imageIndexesToIgnore = <int>[];
    final List<MapEntry<String, FileData>> entries =
        update.images.entries.toList();
    final int length = entries.length;
    bool errors = false;
    for (int i = 0; i < length; i++) {
      final MapEntry<String, FileData> entry = entries[i];
      try {
        await _uploadImage(i, entry.value, update.folder);
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
    FileData fileData,
    Folder folder,
  ) async {
    final StreamController<List<int>> streamController =
        StreamController<List<int>>();
    final int totalSize = fileData.contentSize ?? 100;
    int sent = 0;

    fileData.stream!.listen((List<int> event) {
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

    final String? imageID = await _storage.uploadFile(
        folder.id!, fileData, streamController.stream);

    if (imageID != null) {
      fileData.id = imageID;
      fileData.retrieveThumbnail = true;
      folder.files.putIfAbsent(imageID, () => fileData);

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
    final UpdateDeleteImageEvent update = event.data as UpdateDeleteImageEvent;
    _syncData(
      event,
      () async {
        return _storage.deleteResource(update.imageID);
      },
      (_) {
        update.folder.files.remove(update.imageID);
      },
    );
  }

  void _updateName(EditorEvent event) {
    final UpdateFilenameEvent update = event.data as UpdateFilenameEvent;
    _syncData(
      event,
      () async {
        return _storage.updateFileName(update.folder.id!, update.filename);
      },
      (_) {
        FolderNameData folderNameData =
            FolderNameData.fromFileName(update.filename);
        update.folder.emoji = folderNameData.emoji;
        update.folder.title = folderNameData.title;
      },
    );
  }

  void _updateMetadata(EditorEvent event) {
    final UpdateMetadataEvent update = event.data as UpdateMetadataEvent;
    _syncData(
      event,
      () async {
        return _storage.updateMetadata(
            fileId: update.data.id as String, metadata: update.metadata);
      },
      (_) {
        update.data.metadata = update.metadata;
      },
    );
  }

  void _updatePosition(EditorEvent event) {
    final UpdatePosition update = event.data as UpdatePosition;
    _syncData(
      event,
      () async {
        final double? order = await update.getCurrentItemPosition();
        final Map<String, dynamic> metaData = update.getCurrentItemMetadata();
        metaData.setOrder(order);
        await _storage.updateMetadata(
            fileId: update.getCurrentItemId(), metadata: metaData);
        return order;
      },
      (double? newPosition) {
        if (update.media == true) {
          if (update.folder != null) {
            final FileData? file = update
                .folder!.files[update.items[update.currentIndex].imageKey];
            if (file != null) {
              file.metadata.setOrder(newPosition);
            }
          }
        }
      },
    );
  }

  /// helper method to set the syncing state while calling a method
  Future<void> _syncData(
      EditorEvent event, Function updateMethod, Function successMethod) async {
    add(const EditorEvent(EditorType.syncingState, data: SavingState.saving));
    try {
      final dynamic response = await updateMethod();
      await successMethod(response);
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.success, refreshUI: event.refreshUI));
    } catch (e) {
      add(EditorEvent(EditorType.syncingState,
          data: SavingState.error, refreshUI: event.refreshUI));
    }
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
