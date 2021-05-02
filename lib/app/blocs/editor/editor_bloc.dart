// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/helpers/property.dart' as Prop;
import 'package:web/ui/widgets/story_image.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class EditorBloc extends Bloc<EditorEvent, EditorState?> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  EditorBloc(
      {required GoogleDrive storage,
      required NavigationBloc navigationBloc,
      required Map<String, StoryTimelineData> cloudStories,
      required CloudStoriesBloc cloudStoriesBloc})
      : super(null) {
    _cloudStoriesBloc = cloudStoriesBloc;
    _cloudStories = cloudStories;
    _storage = storage;
    _navigationBloc = navigationBloc;
  }

  late Map<String, StoryTimelineData> _cloudStories;
  late GoogleDrive _storage;
  late NavigationBloc _navigationBloc;
  late CloudStoriesBloc _cloudStoriesBloc;
  late List<int> imageIndexesToIgnore;

  @override
  Stream<EditorState> mapEventToState(EditorEvent event) async* {
    switch (event.type) {
      case EditorType.createStory:
        add(EditorEvent(EditorType.syncingState,
            data: SavingState.saving, refreshUI: event.refreshUI));
        final bool mainEvent =
            Prop.Property.getValueOrDefault(event.mainEvent ?? false, false);
        final String? error =
            await _createEventFolder(event.parentID!, mainEvent);
        if (error == null) {
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.success, refreshUI: event.refreshUI));
        } else {
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.error, refreshUI: event.refreshUI));
        }
        break;
      case EditorType.uploadImages:
        imageIndexesToIgnore = <int>[];
        _uploadImages(
          event.data as Map<String, StoryMedia>,
          event.folderID!,
          event.parentID!,
        );
        break;
      case EditorType.ignoreImage:
        imageIndexesToIgnore = <int>[];
        imageIndexesToIgnore.add(event.data as int);
        break;
      case EditorType.uploadStatus:
        yield EditorState(EditorType.uploadStatus,
            folderID: event.folderID,
            parentID: event.parentID,
            data: event.data,
            error: event.error);
        break;
      case EditorType.deleteStory:
        final String? error =
            await _deleteEvent(event.folderID!, event.parentID);
        if (error == null && event.closeDialog) {
          _navigationBloc.add(NavigatorPopDialogEvent());
        } else {
          yield EditorState(EditorType.deleteStory, error: error);
        }
        break;
      case EditorType.deleteImage:
        add(EditorEvent(EditorType.syncingState,
            data: SavingState.saving, refreshUI: event.refreshUI));
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID!, event.folderID!, _cloudStories)!;
        final String? error = await _deleteFile(event.data as String);
        if (error == null) {
          eventData.images!.remove(event.data);
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.success, refreshUI: event.refreshUI));
          yield EditorState(EditorType.deleteImage, data: event.data);
        } else {
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.error, refreshUI: event.refreshUI));
        }
        break;

      case EditorType.updateName:
        add(EditorEvent(EditorType.syncingState,
            data: SavingState.saving, refreshUI: event.refreshUI));
        _storage
            .updateFileName(event.folderID!, event.data as String)
            .then((value) => {
                  add(EditorEvent(EditorType.syncingState,
                      data: SavingState.success, refreshUI: event.refreshUI))
                });
        break;
      case EditorType.syncingState:
        yield EditorState(EditorType.syncingState,
            data: event.data, refreshUI: event.refreshUI);
        break;
      case EditorType.updateTimestamp:
        add(EditorEvent(EditorType.syncingState,
            data: SavingState.saving, refreshUI: event.refreshUI));
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID!, event.folderID!, _cloudStories)!;
        final int timestamp = event.data as int;
        try {
          await _storage.updateFileName(event.folderID!, timestamp.toString());
          eventData.timestamp = timestamp;
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.success, refreshUI: event.refreshUI));
          yield const EditorState(EditorType.updateTimestamp);
        } catch (e) {
          add(EditorEvent(EditorType.syncingState,
              data: SavingState.error, refreshUI: event.refreshUI));
        }
        break;
      case EditorType.updateMetadata:
        add(EditorEvent(EditorType.syncingState,
            data: SavingState.saving, refreshUI: event.refreshUI));
        _uploadSettingsFile(
                event.folderID!, event.parentID!, event.data as StoryMetadata)
            .then((value) => {
                  add(EditorEvent(EditorType.syncingState,
                      data: SavingState.success, refreshUI: event.refreshUI))
                });
        break;
      case EditorType.updateImagePosition:
        UpdatePosition uip = event.data as UpdatePosition;
        List<StoryImage> images = uip.items as List<StoryImage>;
        int currentIndex = uip.currentIndex;

        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));

        _storage.updatePosition(uip).then((newOrder) {
          final StoryContent? eventData = TimelineService.getStoryWithFolderID(
              event.parentID!, event.folderID!, _cloudStories);

          if (eventData != null) {
            final StoryMedia? oldItem =
                eventData.images?[images[currentIndex].imageKey];
            if (oldItem != null) {
              oldItem.order = newOrder;
            }
          }

          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.success));
        });

        break;
      default:
        break;
    }
  }

  Future<String?> _deleteEvent(String fileID, String? parentID) async {
    _storage.delete(fileID).then((dynamic value) {
      if (parentID != null) {
        final StoryTimelineData story = _cloudStories[parentID]!;
        story.subEvents!
            .removeWhere((StoryContent element) => element.folderID == fileID);
      } else {
        _cloudStories.remove(fileID);
      }
      _cloudStoriesBloc.add(const CloudStoriesEvent(CloudStoriesType.refresh));
      return null;
    }, onError: (_) {
      return 'Error when deleting story';
    });
  }

  Future<String?> _deleteFile(String fileID) async {
    try {
      _storage.delete(fileID);
      return null;
    } catch (e) {
      return 'could not delete $fileID';
    }
  }

  Future<String?> _uploadSettingsFile(
      String folderId, String parentId, StoryMetadata metadata) async {
    final List<int> fileContent = utf8.encode(jsonEncode(metadata));
    final Stream<List<int>> mediaStream =
        Future<List<int>>.value(fileContent).asStream().asBroadcastStream();

    try {
      if (metadata.id != null) {
        await _storage.updateFile(
            metadata.id!, Media(mediaStream, fileContent.length));
      } else {
        metadata.id = await _storage.uploadMedia(
            folderId, Constants.settingsFile, fileContent.length, mediaStream,
            mimeType: 'application/json');
      }

      final StoryContent eventData = TimelineService.getStoryWithFolderID(
          parentId, folderId, _cloudStories)!;
      eventData.metadata = metadata;
      return null;
    } catch (e) {
      return 'Sorry! Could not update';
    }
  }

  Future<String?> _createEventFolder(String parentId, bool mainEvent) async {
    try {
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String? folderID = await _storage.createStory(parentId, timestamp);

      final StoryContent event = StoryContent(
          folderID: folderID!,
          timestamp: timestamp);
      await _uploadSettingsFile(folderID, parentId, event.metadata!);

      if (mainEvent) {
        final StoryTimelineData timelineEvent =
            StoryTimelineData(mainStory: event);
        _cloudStories.putIfAbsent(folderID, () => timelineEvent);
      } else {
        final StoryTimelineData story = _cloudStories[parentId]!;
        story.subEvents!.add(StoryContent(
            folderID: event.folderID,
            timestamp: story.mainStory.timestamp));
      }
      _cloudStoriesBloc
          .add(CloudStoriesEvent(CloudStoriesType.refresh, folderID: folderID));

      return null;
    } catch (e) {
      return 'Error when creating story';
    }
  }

  Future<void> _uploadImages(
      Map<String, StoryMedia> images, String folderID, String parentID) async {
    final List<MapEntry<String, StoryMedia>> entries = images.entries.toList();
    final int length = entries.length;
    bool errors = false;
    for (int i = 0; i < length; i++) {
      final MapEntry<String, StoryMedia> entry = entries[i];
      try {
        await _uploadImage(i, entry.key, entry.value, folderID, parentID);
      } catch (e) {
        errors = true;
        add(EditorEvent(EditorType.uploadStatus,
            folderID: folderID,
            parentID: parentID,
            data: MediaProgress(i, 0, 0),
            error: 'Could not upload'));
      }
    }

    _cloudStoriesBloc.add(const CloudStoriesEvent(CloudStoriesType.refresh));
    if (!errors) {
      _navigationBloc.add(NavigatorPopEvent());
    }
  }

  Future<void> _uploadImage(
    int index,
    String name,
    StoryMedia storyMedia,
    String folderID,
    String parentID,
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
            folderID: folderID,
            parentID: parentID,
            data: MediaProgress(index, totalSize, sent)));
        streamController.add(event);
      }
    }, onDone: () {
      streamController.close();
    }, onError: (dynamic error) {
      streamController.close();
    });

    final String? imageID = await _storage.uploadMediaToFolder(
        folderID, name, storyMedia, streamController.stream);

    if (imageID != null) {
      final StoryContent? eventData = TimelineService.getStoryWithFolderID(
          parentID, folderID, _cloudStories);
      storyMedia.id = imageID;
      storyMedia.retrieveThumbnail = true;
      eventData!.images!.putIfAbsent(imageID, () => storyMedia);

      add(EditorEvent(EditorType.uploadStatus,
          folderID: folderID,
          parentID: parentID,
          data: MediaProgress(index, totalSize, sent)));
    } else {
      throw 'Error when creating image';
    }
  }
}
