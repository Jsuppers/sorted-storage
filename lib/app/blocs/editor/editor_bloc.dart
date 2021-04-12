import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/comments_response.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/story_comments.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/helpers/property.dart' as Prop;
import 'package:web/ui/widgets/story_image.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  EditorBloc(
      {GoogleDrive storage,
      NavigationBloc navigationBloc,
      Map<String, StoryTimelineData> cloudStories,
      CloudStoriesBloc cloudStoriesBloc})
      : super(null) {
    _cloudStoriesBloc = cloudStoriesBloc;
    _cloudStories = cloudStories;
    _storage = storage;
    _navigationBloc = navigationBloc;
  }

  Map<String, StoryTimelineData> _cloudStories;
  GoogleDrive _storage;
  NavigationBloc _navigationBloc;
  CloudStoriesBloc _cloudStoriesBloc;
  List<int> imageIndexesToIgnore;

  @override
  Stream<EditorState> mapEventToState(EditorEvent event) async* {
    switch (event.type) {
      case EditorType.createStory:
        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));
        final bool mainEvent =
            Prop.Property.getValueOrDefault(event.mainEvent, false);
        final String error =
        await _createEventFolder(event.parentID, mainEvent);
        if (error == null) {
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.success));
        } else {
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.error));
        }
        break;
      case EditorType.uploadImages:
        imageIndexesToIgnore = <int>[];
        _uploadImages(
          event.data as Map<String, StoryMedia>,
          event.folderID,
          event.parentID,
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
        final String error = await _deleteEvent(event.folderID, event.parentID);
        if (error == null && event.closeDialog) {
          _navigationBloc.add(NavigatorPopDialogEvent());
        } else {
          yield EditorState(EditorType.deleteStory, error: error);
        }
        break;
      case EditorType.deleteImage:
        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _cloudStories);
        final String error = await _deleteFile(event.data as String);
        if (error == null) {
          eventData.images.remove(event.data);
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.success));
          yield EditorState(EditorType.deleteImage, data: event.data);
        } else {
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.error));
        }
        break;

      case EditorType.syncingState:
        yield EditorState(EditorType.syncingState, data: event.data);
        break;
      case EditorType.updateTimestamp:
        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _cloudStories);
        final int timestamp = event.data as int;
        try {
          await _storage.updateEventFolderTimestamp(event.folderID, timestamp);
          eventData.timestamp = timestamp;
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.success));
          yield const EditorState(EditorType.updateTimestamp);
        } catch (e) {
          add(const EditorEvent(EditorType.syncingState,
              data: SavingState.error));
        }
        break;
      case EditorType.updateMetadata:
        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));
        _uploadSettingsFile(
            event.folderID, event.parentID, event.data as StoryMetadata);
        break;
      case EditorType.updateImagePosition:
        add(const EditorEvent(EditorType.syncingState,
            data: SavingState.saving));
        _updatePosition(event.data as List<StoryImage>, event.parentID);
        break;
//      case CloudStoriesType.deleteImage:
//        final StoryContent eventData = TimelineService.getStoryWithFolderID(
//            event.parentID, event.folderID, _localStories);
//        eventData.images.remove(event.data);
//        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
//            folderID: event.folderID);
//        break;

//      case CloudStoriesType.syncingEnd:
////        _localStories[event.folderID].saving = false;
////        _localStories[event.folderID].locked = true;
//        yield CloudStoriesState(CloudStoriesType.syncingEnd, _cloudStories,
//            folderID: event.folderID, data: event.data);
//        break;
//      case CloudStoriesType.syncingState:
//        yield CloudStoriesState(CloudStoriesType.syncingState, _cloudStories,
//            folderID: event.folderID, data: event.data);
//        break;

//      case LocalStoriesType.cancelStory:
//        _localStories[event.folderID] = StoryTimelineData.clone(
//            event.data[event.folderID] as StoryTimelineData);
//        _localStories[event.folderID].locked = true;
//        yield LocalStoriesState(LocalStoriesType.cancelStory, _localStories,
//            folderID: event.folderID);
//        break;
//      case LocalStoriesType.editStory:
//        _localStories[event.folderID].locked = false;
//        yield LocalStoriesState(LocalStoriesType.editStory, _localStories,
//            folderID: event.folderID);
//        break;
//      case CloudStoriesType.syncingStart:
//        _localStories[event.folderID].saving = true;
//        yield CloudStoriesState(CloudStoriesType.syncingStart, _cloudStories,
//            folderID: event.folderID);
//        _syncCopies(event.folderID);
      default:
        break;
    }
  }

  Future<String> _deleteEvent(String fileID, String parentID) async {
    _storage.delete(fileID).then((dynamic value) {
      if (parentID != null) {
        final StoryTimelineData story = _cloudStories[parentID];
        story.subEvents
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

  Future<String> _deleteFile(String fileID) async {
    _storage.delete(fileID);
  }

  Future<void> _updatePosition(List<StoryImage> images, String parentID) async {
    // TODO error
    for (int i = 0; i < images.length; i++) {
      // TODO transactions
      await _storage.updatePosition(
          images[i].imageKey, images[i].storyMedia.index);
      TimelineService.updateImage(images[i].imageKey,
          images[i].storyMedia.index, _cloudStories[parentID]);
    }
    add(const EditorEvent(EditorType.syncingState,
        data: SavingState.success));
  }

  Future<String> _uploadSettingsFile(
      String folderId, String parentId, StoryMetadata metadata) async {
    final String jsonString = jsonEncode(metadata);
    final List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future<List<int>>.value(fileContent).asStream().asBroadcastStream();

    try {
      if (metadata.id != null) {
        await _storage.updateFile(
            null, metadata.id, Media(mediaStream, fileContent.length));
      } else {
        metadata.id = await _storage.uploadMedia(
            folderId, Constants.settingsFile, fileContent.length, mediaStream,
            mimeType: 'application/json');
      }

      final StoryContent eventData = TimelineService.getStoryWithFolderID(
          parentId, folderId, _cloudStories);
      eventData.metadata = metadata;
      add(const EditorEvent(EditorType.syncingState,
          data: SavingState.success));
      return null;
    } catch (e) {
      return 'Sorry! Could not update';
    }
  }

  Future<String> _createEventFolder(String parentId, bool mainEvent) async {
    try {
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String folderID = await _storage.createStory(parentId, timestamp);

      final StoryContent event = StoryContent(
          comments: StoryComments(), folderID: folderID, timestamp: timestamp);
      await _uploadSettingsFile(folderID, parentId, event.metadata);

      if (mainEvent) {
        final CommentsResponse commentsResponse =
            await _storage.uploadCommentsFile(folderID: event.folderID);
        event.comments = commentsResponse.comments;
        event.commentsID = commentsResponse.commentsID;
        final StoryTimelineData timelineEvent =
            StoryTimelineData(mainStory: event);
        _cloudStories.putIfAbsent(folderID, () => timelineEvent);
      } else {
        final StoryTimelineData story = _cloudStories[parentId];
        story.subEvents.add(StoryContent(
            folderID: event.folderID,
            timestamp: story.mainStory.timestamp,
            comments: StoryComments()));
      }
      _cloudStoriesBloc.add(const CloudStoriesEvent(CloudStoriesType.refresh));

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
    final int totalSize = storyMedia.contentSize;
    int sent = 0;

    storyMedia.stream.listen((List<int> event) {
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

    final String imageID = await _storage.uploadMediaToFolder(
        folderID, name, storyMedia, streamController.stream);

    if (imageID != null) {
      final StoryContent eventData = TimelineService.getStoryWithFolderID(
          parentID, folderID, _cloudStories);
      eventData.images.putIfAbsent(imageID, () => storyMedia);

      add(EditorEvent(EditorType.uploadStatus,
          folderID: folderID,
          parentID: parentID,
          data: MediaProgress(index, totalSize, sent)));
    } else {
      throw 'Error when creating image';
    }
  }

//
//
//  Future<void> _syncContent(StoryContent localCopy, StoryContent cloudCopy,
//      List<String> errorMessages) async {
//    List<Future<dynamic>> tasks = <Future<dynamic>>[];
//    final Map<String, List<String>> uploadingImages = <String, List<String>>{};
//
//
//    await Future.wait(tasks);
//    tasks = <Future<dynamic>>[];
//
//    final Map<String, StoryMedia> imagesToAdd = <String, StoryMedia>{};
//    final List<String> imagesToDelete = <String>[];
//
//    if (localCopy.images != null) {
//      int totalSize = 0;
//      int sent = 0;
//      for (int i = 0; i < localCopy.images.length; i++) {
//        final MapEntry<String, StoryMedia> image =
//        localCopy.images.entries.elementAt(i);
//        if (!cloudCopy.images.containsKey(image.key)) {
//          totalSize += image.value.contentSize;
//          uploadingImages.update(localCopy.folderID, (List<String> value) {
//            value.add(image.key);
//            return value;
//          }, ifAbsent: () {
//            return <String>[image.key];
//          });
//        } else {
//          final int newIndex = localCopy.images[image.key].index;
//          final int oldIndex = cloudCopy.images[image.key].index;
//          if (newIndex != oldIndex) {
//            tasks.add(_storage
//                .updatePosition(image.key, newIndex)
//                .then((_) => cloudCopy.images[image.key].index = newIndex,
//                onError: (_) {
//                  errorMessages.add('Set index for Image');
//                  localCopy.images[image.key].index = oldIndex;
//                }));
//          }
//        }
//      }
//
//      add(CloudStoriesEvent(CloudStoriesType.progressUpload,
//          folderID: localCopy.folderID, data: MediaProgress(totalSize, sent)));
//      add(CloudStoriesEvent(CloudStoriesType.syncingState,
//          folderID: localCopy.folderID, data: uploadingImages));
//
//      for (int i = 0; i < localCopy.images.length; i++) {
//        final MapEntry<String, StoryMedia> image =
//        localCopy.images.entries.elementAt(i);
//        if (!cloudCopy.images.containsKey(image.key)) {
//          final StreamController<List<int>> streamController =
//          StreamController<List<int>>();
//
//          image.value.stream.listen((List<int> event) {
//            sent += event.length;
//            add(CloudStoriesEvent(CloudStoriesType.progressUpload,
//                folderID: localCopy.folderID,
//                data: MediaProgress(totalSize, sent)));
//            streamController.add(event);
//          }, onDone: () {
//            streamController.close();
//          }, onError: (dynamic error) {
//            streamController.close();
//          });
//
//          await _storage
//              .uploadMediaToFolder(
//              cloudCopy, image.key, image.value, streamController.stream)
//              .then((String imageID) {
//            if (imageID != null) {
//              imagesToAdd.putIfAbsent(imageID, () => image.value);
//            }
//          }, onError: (dynamic error) {
//            errorMessages.add('Add Image ${image.key}');
//          });
//
//          uploadingImages.update(localCopy.folderID, (List<String> value) {
//            value.remove(image.key);
//            return value;
//          });
//          add(CloudStoriesEvent(CloudStoriesType.syncingState,
//              folderID: localCopy.folderID, data: uploadingImages));
//        }
//      }
//
//      for (final MapEntry<String, StoryMedia> image
//      in cloudCopy.images.entries) {
//        if (!localCopy.images.containsKey(image.key)) {
//          tasks.add(_storage.delete(image.key).then((_) {
//            imagesToDelete.add(image.key);
//          }, onError: (dynamic error) {
//            errorMessages.add('Delete Image ${image.key}');
//          }));
//        }
//      }
//    }
//
//    await Future.wait(tasks).then((_) {
//      cloudCopy.images.removeWhere(
//              (String key, StoryMedia value) => imagesToDelete.contains(key));
//      cloudCopy.images.addAll(imagesToAdd);
//
//      final Map<String, StoryMedia> imagesCopy = <String, StoryMedia>{};
//      for (final MapEntry<String, StoryMedia> image
//      in cloudCopy.images.entries) {
//        imagesCopy.putIfAbsent(image.key, () => StoryMedia.clone(image.value));
//      }
//
//      localCopy.images = imagesCopy;
//
//      imagesToAdd.forEach((String key, StoryMedia value) {
//        RetryService.getThumbnail(_storage, localCopy.folderID, key,
//            localCopy.images, uploadingImages, () {
//              add(CloudStoriesEvent(CloudStoriesType.syncingState,
//                  folderID: localCopy.folderID, data: uploadingImages));
//            });
//      });
//      RetryService.checkNeedsRefreshing(
//          localCopy.folderID, uploadingImages, localCopy, () {
//        add(CloudStoriesEvent(CloudStoriesType.syncingState,
//            folderID: localCopy.folderID, data: uploadingImages));
//      });
//    });
//  }

//    bool rebuildAllStories = false;
//    final List<String> errorMessages = <String>[];
//    StoryTimelineData localCopy = _localStories[eventFolderID];
//    final StoryTimelineData cloudCopy = _cloudStories[eventFolderID];
//    if (localCopy.mainStory.timestamp != cloudCopy.mainStory.timestamp) {
//      rebuildAllStories = true;
//    }
//    for (int i = 0; i < localCopy.subEvents.length; i++) {
//      final StoryContent subEvent = localCopy.subEvents[i];
//      StoryContent cloudSubEvent;
//      if (subEvent.folderID.startsWith('temp_')) {
//        cloudSubEvent =
//            await _createEventFolder(eventFolderID, subEvent.timestamp, false);
//        cloudCopy.subEvents.add(cloudSubEvent);
//        subEvent.folderID = cloudSubEvent.folderID;
//        subEvent.settingsID = cloudSubEvent.settingsID;
//      } else {
//        cloudSubEvent = cloudCopy.subEvents.singleWhere(
//            (StoryContent element) => element.folderID == subEvent.folderID);
//      }
//
//      await _syncContent(subEvent, cloudSubEvent, errorMessages);
//    }
//
//    final List<StoryContent> eventsToDelete = <StoryContent>[];
//    for (final StoryContent subEvent in cloudCopy.subEvents) {
//      StoryContent localEvent;
//      for (int i = 0; i < localCopy.subEvents.length; i++) {
//        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
//          localEvent = localCopy.subEvents[i];
//          break;
//        }
//      }
//      if (localEvent == null) {
//        await _storage.delete(subEvent.folderID);
//        eventsToDelete.add(subEvent);
//      }
//    }
//
//    for (final StoryContent subEvent in eventsToDelete) {
//      cloudCopy.subEvents.remove(subEvent);
//    }
//
//    await _syncContent(localCopy.mainStory, cloudCopy.mainStory, errorMessages);
//    localCopy = StoryTimelineData.clone(cloudCopy);
//
//    add(CloudStoriesEvent(CloudStoriesType.syncingEnd,
//        folderID: eventFolderID, data: errorMessages));
//
//    if (rebuildAllStories) {
//      add(CloudStoriesEvent(CloudStoriesType.updateUI,
//          folderID: eventFolderID));
//    }

}
