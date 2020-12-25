import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/comments_response.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/story_comments.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/sub_event.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/constants.dart';

/// CloudStoriesBloc handles all the cloud changes of the timeline.
class CloudStoriesBloc extends Bloc<CloudStoriesEvent, CloudStoriesState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  CloudStoriesBloc(
      {Map<String, StoryTimelineData> localStories, GoogleDrive storage})
      : super(const CloudStoriesState(CloudStoriesType.initialState, null)) {
    _localStories = localStories;
    _storage = storage;
  }

  Map<String, StoryTimelineData> _cloudStories;
  Map<String, StoryTimelineData> _localStories;
  GoogleDrive _storage;
  String _mediaFolderID;

  /// returns the current cloud copy of the timeline
  Map<String, StoryTimelineData> get cloudStories {
    return _cloudStories;
  }

  @override
  Stream<CloudStoriesState> mapEventToState(CloudStoriesEvent event) async* {
    if (event.type == CloudStoriesType.newUser) {
      _mediaFolderID = null;
      _cloudStories = null;
      _localStories.clear();
      yield CloudStoriesState(CloudStoriesType.initialState, _cloudStories);
      return;
    }

    if (event.type == CloudStoriesType.retrieveStory ||
        event.type == CloudStoriesType.retrieveStories) {
      _getStories(folderID: event.folderID);
      return;
    }

    switch (event.type) {
      case CloudStoriesType.deleteStory:
        yield CloudStoriesState(CloudStoriesType.syncingStart, _cloudStories,
            folderID: event.folderID);
        _deleteEvent(event.folderID);
        break;
      case CloudStoriesType.syncingStart:
        _localStories[event.folderID].saving = true;
        _syncCopies(event.folderID);
        yield CloudStoriesState(CloudStoriesType.syncingStart, _cloudStories,
            folderID: event.folderID);
        break;
      case CloudStoriesType.createStory:
        _createEventFolder(_mediaFolderID, event.data as int, event.mainEvent);
        break;
      case CloudStoriesType.updateUI:
        yield CloudStoriesState(CloudStoriesType.updateUI, _cloudStories);
        break;
      case CloudStoriesType.syncingEnd:
        _localStories[event.folderID].saving = false;
        _localStories[event.folderID].locked = true;
        yield CloudStoriesState(CloudStoriesType.syncingEnd, _cloudStories,
            folderID: event.folderID);
        break;
      case CloudStoriesType.syncingState:
        yield CloudStoriesState(CloudStoriesType.syncingState, _cloudStories,
            folderID: event.folderID, data: event.data);
        break;
      case CloudStoriesType.progressUpload:
        yield CloudStoriesState(CloudStoriesType.progressUpload, _cloudStories,
            folderID: event.folderID, data: event.data);
        break;
      default:
        break;
    }
  }

  Future<void> _deleteEvent(String fileID) async {
    _storage.delete(fileID).then((dynamic value) {
      _cloudStories.remove(fileID);
      _localStories.remove(fileID);
      add(const CloudStoriesEvent(CloudStoriesType.updateUI));
    });
  }

  Future<void> _syncCopies(String eventFolderID) async {
    bool rebuildAllStories = false;
    StoryTimelineData localCopy = _localStories[eventFolderID];
    final StoryTimelineData cloudCopy = _cloudStories[eventFolderID];
    if (localCopy.mainStory.timestamp != cloudCopy.mainStory.timestamp) {
      rebuildAllStories = true;
    }
    for (int i = 0; i < localCopy.subEvents.length; i++) {
      final StoryContent subEvent = localCopy.subEvents[i];
      StoryContent cloudSubEvent;
      if (subEvent.folderID.startsWith('temp_')) {
        cloudSubEvent =
            await _createEventFolder(eventFolderID, subEvent.timestamp, false);
        cloudCopy.subEvents.add(cloudSubEvent);
        subEvent.folderID = cloudSubEvent.folderID;
        subEvent.settingsID = cloudSubEvent.settingsID;
      } else {
        cloudSubEvent = cloudCopy.subEvents.singleWhere(
            (StoryContent element) => element.folderID == subEvent.folderID);
      }

      await _syncContent(subEvent, cloudSubEvent);
    }

    final List<StoryContent> eventsToDelete = <StoryContent>[];
    for (final StoryContent subEvent in cloudCopy.subEvents) {
      StoryContent localEvent;
      for (int i = 0; i < localCopy.subEvents.length; i++) {
        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
          localEvent = localCopy.subEvents[i];
          break;
        }
      }
      if (localEvent == null) {
        await _storage.delete(subEvent.folderID);
        eventsToDelete.add(subEvent);
      }
    }

    for (final StoryContent subEvent in eventsToDelete) {
      cloudCopy.subEvents.remove(subEvent);
    }

    await _syncContent(localCopy.mainStory, cloudCopy.mainStory);
    localCopy = StoryTimelineData.clone(cloudCopy);

    add(CloudStoriesEvent(CloudStoriesType.syncingEnd,
        folderID: eventFolderID));

    if (rebuildAllStories) {
      add(CloudStoriesEvent(CloudStoriesType.updateUI,
          folderID: eventFolderID));
    }
  }

  Future<void> _syncContent(
      StoryContent localCopy, StoryContent cloudCopy) async {
    List<Future<dynamic>> tasks = <Future<dynamic>>[];
    final Map<String, List<String>> uploadingImages = <String, List<String>>{};

    if (localCopy.timestamp != cloudCopy.timestamp) {
      tasks.add(_storage
          .updateEventFolderTimestamp(localCopy.folderID, localCopy.timestamp)
          .then((String value) {
        cloudCopy.timestamp = localCopy.timestamp;
      }, onError: (dynamic error) {
        print('error $error');
      }));
    }

    if (localCopy.title != cloudCopy.title ||
        localCopy.description != cloudCopy.description ||
        localCopy.emoji != cloudCopy.emoji) {
      tasks.add(_uploadSettingsFile(cloudCopy.folderID, localCopy).then(
          (String settingsID) {
        cloudCopy.settingsID = settingsID;
        cloudCopy.title = localCopy.title;
        cloudCopy.description = localCopy.description;
        cloudCopy.emoji = localCopy.emoji;
      }, onError: (dynamic error) {
        print('error $error');
      }));
    }

    await Future.wait(tasks);
    tasks = <Future<dynamic>>[];

    final Map<String, StoryMedia> imagesToAdd = <String, StoryMedia>{};
    final List<String> imagesToDelete = <String>[];
    final List<String> localImagesToDelete = <String>[];
    if (localCopy.images != null) {
      int totalSize = 0;
      int sent = 0;
      for (int i = 0; i < localCopy.images.length; i++) {
        final MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          totalSize += image.value.contentSize;
          uploadingImages.update(localCopy.folderID, (List<String> value) {
            value.add(image.key);
            return value;
          }, ifAbsent: () {
            return <String>[image.key];
          });
        }
      }

      add(CloudStoriesEvent(CloudStoriesType.progressUpload,
          folderID: localCopy.folderID, data: MediaProgress(totalSize, sent)));
      add(CloudStoriesEvent(CloudStoriesType.syncingState,
          folderID: localCopy.folderID, data: uploadingImages));

      for (int i = 0; i < localCopy.images.length; i++) {
        final MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          final StreamController<List<int>> streamController =
              StreamController<List<int>>();

          image.value.stream.listen((List<int> event) {
            sent += event.length;
            add(CloudStoriesEvent(CloudStoriesType.progressUpload,
                folderID: localCopy.folderID,
                data: MediaProgress(totalSize, sent)));
            streamController.add(event);
          }, onDone: () {
            streamController.close();
          }, onError: (dynamic error) {
            print('error: $error');
            streamController.close();
          });

          await _storage
              .uploadMediaToFolder(cloudCopy, image.key, image.value, 10,
                  streamController.stream)
              .then((String imageID) {
            uploadingImages.update(localCopy.folderID, (List<String> value) {
              value.remove(image.key);
              return value;
            });
            add(CloudStoriesEvent(CloudStoriesType.syncingState,
                folderID: localCopy.folderID, data: uploadingImages));

            if (imageID != null) {
              imagesToAdd.putIfAbsent(imageID, () => image.value);
              localImagesToDelete.add(image.key);
            }
          }, onError: (dynamic error) {
            print('error $error');
          });
        }
      }

      for (final MapEntry<String, StoryMedia> image
          in cloudCopy.images.entries) {
        if (!localCopy.images.containsKey(image.key)) {
          tasks.add(_storage.delete(image.key).then((_) {
            imagesToDelete.add(image.key);
          }, onError: (dynamic error) {
            print('error $error');
          }));
        }
      }
    }

    return Future.wait(tasks).then((_) {
      cloudCopy.images.addAll(imagesToAdd);
      localCopy.images.addAll(imagesToAdd);
      cloudCopy.images.removeWhere(
          (String key, StoryMedia value) => imagesToDelete.contains(key));
      localCopy.images.removeWhere(
          (String key, StoryMedia value) => localImagesToDelete.contains(key));
      imagesToAdd.forEach((String key, StoryMedia value) {
        RetryService.getThumbnail(_storage, localCopy.folderID, key,
            localCopy.images, uploadingImages, () {
          add(CloudStoriesEvent(CloudStoriesType.syncingState,
              folderID: localCopy.folderID, data: uploadingImages));
        });
      });
      RetryService.checkNeedsRefreshing(
          localCopy.folderID, uploadingImages, localCopy, () {
        add(CloudStoriesEvent(CloudStoriesType.syncingState,
            folderID: localCopy.folderID, data: uploadingImages));
      });
    });
  }

  Future<StoryContent> _createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
    try {
      final String folderID = await _storage.createStory(parentId, timestamp);

      final StoryContent event = StoryContent(
          comments: StoryComments(), folderID: folderID, timestamp: timestamp);
      event.settingsID = await _uploadSettingsFile(folderID, event);

      if (mainEvent) {
        final CommentsResponse commentsResponse =
            await _storage.uploadCommentsFile(folderID: event.folderID);
        event.comments = commentsResponse.comments;
        event.commentsID = commentsResponse.commentsID;
        final StoryTimelineData timelineEvent =
            StoryTimelineData(mainStory: event, subEvents: []);
        _cloudStories.putIfAbsent(folderID, () => timelineEvent);
        _localStories.putIfAbsent(
            folderID, () => StoryTimelineData.clone(timelineEvent));
      }

      if (mainEvent) {
        add(const CloudStoriesEvent(CloudStoriesType.updateUI));
      }
      return event;
    } catch (e) {
      print('error: $e');
    }
    return null;
  }

  Future<String> _uploadSettingsFile(
      String parentId, StoryContent content) async {
    final StorySettings settings = StorySettings(
        title: content.title,
        description: content.description,
        emoji: content.emoji);
    final String jsonString = jsonEncode(settings);
    final List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    if (content.settingsID != null) {
      final File folder = await _storage.updateFile(
          null, content.settingsID, Media(mediaStream, fileContent.length));
      return folder.id;
    }

    final String folderID = await _storage.uploadMedia(
        parentId, Constants.SETTINGS_FILE, fileContent.length, mediaStream,
        mimeType: 'application/json');
    return folderID;
  }

  void _getStories({String folderID}) {
    if (_cloudStories == null) {
      _cloudStories = <String, StoryTimelineData>{};
      if (folderID != null) {
        _getViewEvent(folderID).then(
            (_) => add(const CloudStoriesEvent(CloudStoriesType.updateUI)));
      } else {
        _getMediaFolder().then((String value) {
          _mediaFolderID = value;
          _getEventsFromFolder(value).then(
              (_) => add(const CloudStoriesEvent(CloudStoriesType.updateUI)));
        });
      }
    }
  }

  Future<void> _getEventsFromFolder(String folderID) async {
    try {
      final FileList eventList = await _storage.listFiles(
          "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");
      final List<String> folderIds = <String>[];
      final List<Future<dynamic>> tasks = <Future<dynamic>>[];
      for (final File file in eventList.files) {
        final int timestamp = int.tryParse(file.name);

        if (timestamp != null) {
          folderIds.add(file.id);
          tasks.add(_createEventFromFolder(file.id, timestamp)
              .then((StoryContent mainEvent) async {
            final List<StoryContent> subEvents = <StoryContent>[];
            for (final SubEvent subEvent in mainEvent.subEvents) {
              subEvents.add(await _createEventFromFolder(
                  subEvent.id, subEvent.timestamp));
            }

            final StoryTimelineData data =
                StoryTimelineData(mainStory: mainEvent, subEvents: subEvents);
            _cloudStories.putIfAbsent(file.id, () => data);
            _localStories.putIfAbsent(
                file.id, () => StoryTimelineData.clone(data));
          }));
        }
      }
      await Future.wait(tasks);
    } catch (e) {
      print('error: $e');
    } finally {}
  }

  Future<void> _getViewEvent(String folderID) async {
    final dynamic folder = await _storage.getFile(folderID);
    if (folder == null) {
      return;
    }
    final int timestamp = int.tryParse(folder.name as String);
    if (timestamp == null) {
      return;
    }
    final StoryContent mainEvent =
        await _createEventFromFolder(folderID, timestamp);

    final List<StoryContent> subEvents = <StoryContent>[];
    for (final SubEvent subEvent in mainEvent.subEvents) {
      subEvents
          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
    }
    final StoryTimelineData timelineData =
        StoryTimelineData(mainStory: mainEvent, subEvents: subEvents);
    _localStories.putIfAbsent(folderID, () => timelineData);
    _cloudStories.putIfAbsent(
        folderID, () => StoryTimelineData.clone(timelineData));
  }

  Future<String> _getMediaFolder() async {
    try {
      String mediaFolderID;

      final String query =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.ROOT_FOLDER}' and trashed=false";
      final FileList folderParent = await _storage.listFiles(query);
      String parentId;

      if (folderParent.files.isEmpty) {
        final File fileMetadata = File();
        fileMetadata.name = Constants.ROOT_FOLDER;
        fileMetadata.mimeType = 'application/vnd.google-apps.folder';
        fileMetadata.description = "please don't modify this folder";
        final File rt = await _storage.createFile(fileMetadata);
        parentId = rt.id;
      } else {
        parentId = folderParent.files.first.id;
      }

      final String query2 =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.MEDIA_FOLDER}' and '$parentId' in parents and trashed=false";
      final FileList folder = await _storage.listFiles(query2);

      if (folder.files.isEmpty) {
        final File mediaFolder = File();
        mediaFolder.name = Constants.MEDIA_FOLDER;
        mediaFolder.parents = <String>[parentId];
        mediaFolder.mimeType = 'application/vnd.google-apps.folder';
        mediaFolder.description = "please don't modify this folder";

        final File folder = await _storage.createFile(mediaFolder);
        mediaFolderID = folder.id;
      } else {
        mediaFolderID = folder.files.first.id;
      }

      return mediaFolderID;
    } catch (e) {
      print('error: $e');
      return e.toString();
    } finally {}
  }

  Future<StoryContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    final FileList filesInFolder = await _storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter: 'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink)');

    String settingsID;
    String commentsID;
    final Map<String, StoryMedia> images = <String, StoryMedia>{};
    final List<SubEvent> subEvents = <SubEvent>[];
    for (final File file in filesInFolder.files) {
      if (file.mimeType.startsWith('image/') ||
          file.mimeType.startsWith('video/')) {
        final StoryMedia media = StoryMedia();
        media.isVideo = file.mimeType.startsWith('video/');
        if (file.hasThumbnail) {
          media.thumbnailURL = file.thumbnailLink;
        }
        images.putIfAbsent(file.id, () => media);
      } else if (file.name == Constants.SETTINGS_FILE) {
        settingsID = file.id;
      } else if (file.name == Constants.COMMENTS_FILE) {
        commentsID = file.id;
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final int timestamp = int.tryParse(file.name);
        if (timestamp != null) {
          subEvents.add(SubEvent(file.id, timestamp));
        }
      } else {
        final StoryMedia media = StoryMedia();
        media.isDocument = true;
        if (file.hasThumbnail) {
          media.thumbnailURL = file.thumbnailLink;
        }
        images.putIfAbsent(file.id, () => media);
      }
    }

    final StorySettings settings =
        StorySettings.fromJson(await _storage.getJsonFile(settingsID));

    final StoryComments comments =
        StoryComments.fromJson(await _storage.getJsonFile(commentsID));

    return StoryContent(
        timestamp: timestamp,
        images: images,
        title: settings.title,
        comments: comments,
        commentsID: commentsID,
        emoji: settings.emoji,
        description: settings.description,
        subEvents: subEvents,
        settingsID: settingsID,
        folderID: folderID);
  }
}
