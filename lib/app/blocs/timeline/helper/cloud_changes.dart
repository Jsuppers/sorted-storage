import 'dart:async';
import 'dart:convert';

import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CloudChanges {
  GoogleDrive storage;
  String mediaFolderID;
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;

  CloudChanges(this.storage, this.cloudStories, this.localStories, this.mediaFolderID);

  Stream<TimelineState> changeCloudState(
      TimelineCloudEvent event, Function(TimelineEvent) updateCallback) async* {
    switch (event.type) {
      case TimelineMessageType.delete_story:
        yield TimelineState(
            TimelineMessageType.syncing_story_start, localStories,
            folderID: event.folderId);
        _deleteEvent(event.folderId, updateCallback: updateCallback);
        break;
      case TimelineMessageType.syncing_story_start:
        localStories[event.folderId].saving = true;
        syncCopies(event.folderId,
            updateCallback: updateCallback);
        yield TimelineState(
            TimelineMessageType.syncing_story_start, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.create_story:
        createEventFolder(
            mediaFolderID, event.data, event.mainEvent,
            updateCallback: updateCallback);
        break;
      default:
        break;
    }
  }

  Future _deleteEvent(fileId,  {Function(TimelineEvent) updateCallback}) async {
    storage.delete(fileId).then((value) {
      cloudStories.remove(fileId);
      localStories.remove(fileId);
      updateCallback(TimelineEvent(TimelineMessageType.updated_stories));
    });
  }

  Future syncCopies(String eventFolderID,
      {Function(TimelineEvent) updateCallback}) async {
    bool rebuildAllStories = false;
    var localCopy = localStories[eventFolderID];
    var cloudCopy = cloudStories[eventFolderID];
    if (localCopy.mainEvent.timestamp != cloudCopy.mainEvent.timestamp) {
      rebuildAllStories = true;
    }
    for (int i = 0; i < localCopy.subEvents.length; i++) {
      EventContent subEvent = localCopy.subEvents[i];
      EventContent cloudSubEvent;
      if (subEvent.folderID.startsWith("temp_")) {
        cloudSubEvent =
            await createEventFolder(eventFolderID, subEvent.timestamp, false);
        cloudCopy.subEvents.add(cloudSubEvent);
        subEvent.folderID = cloudSubEvent.folderID;
        subEvent.settingsID = cloudSubEvent.settingsID;
      } else {
        cloudSubEvent = cloudCopy.subEvents
            .singleWhere((element) => element.folderID == subEvent.folderID);
      }

      await _syncContent(subEvent, cloudSubEvent,
          updateCallback: updateCallback);
    }

    List<EventContent> eventsToDelete = [];
    for (EventContent subEvent in cloudCopy.subEvents) {
      EventContent localEvent;
      for (int i = 0; i < localCopy.subEvents.length; i++) {
        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
          localEvent = localCopy.subEvents[i];
          break;
        }
      }
      if (localEvent == null) {
        await storage.delete(subEvent.folderID);
        eventsToDelete.add(subEvent);
      }
    }

    for (EventContent subEvent in eventsToDelete) {
      cloudCopy.subEvents.remove(subEvent);
    }

    await _syncContent(localCopy.mainEvent, cloudCopy.mainEvent,
        updateCallback: updateCallback);
    localCopy = TimelineData.clone(cloudCopy);

    updateCallback(TimelineEvent(TimelineMessageType.syncing_story_end,
        folderId: eventFolderID));
    if (rebuildAllStories) {
      updateCallback(TimelineEvent(TimelineMessageType.updated_stories));
    }
  }

  Future _syncContent(EventContent localCopy, EventContent cloudCopy,
      {Function(TimelineEvent) updateCallback}) async {
    List<Future> tasks = [];
    Map<String, List<String>> uploadingImages = Map();

    print('updating cloud storage');
    if (localCopy.timestamp != cloudCopy.timestamp) {
      tasks.add(storage
          .updateEventFolderTimestamp(localCopy.folderID, localCopy.timestamp)
          .then((value) {
        cloudCopy.timestamp = localCopy.timestamp;
      }, onError: (error) {
        print('error $error');
      }));
      print("timestamp is different!");
    }

    if (localCopy.title != cloudCopy.title ||
        localCopy.description != cloudCopy.description ||
        localCopy.emoji != cloudCopy.emoji) {
      print('updating settings storage');
      tasks.add(
          _uploadSettingsFile(cloudCopy.folderID, localCopy).then((settingsId) {
        cloudCopy.settingsID = settingsId;
        cloudCopy.title = localCopy.title;
        cloudCopy.description = localCopy.description;
        cloudCopy.emoji = localCopy.emoji;
      }, onError: (error) {
        print('error $error');
      }));
    }

    print('uploading misc files');
    await Future.wait(tasks);
    tasks = [];
    print('starting on images');

    Map<String, StoryMedia> imagesToAdd = Map();
    List<String> imagesToDelete = [];
    List<String> localImagesToDelete = [];
    if (localCopy.images != null) {
      // inform the frontend which files need to upload
      int totalSize = 0;
      int sent = 0;
      for (int i = 0; i < localCopy.images.length; i++) {
        MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          totalSize += image.value.size;
          uploadingImages.update(localCopy.folderID, (value) {
            value.add(image.key);
            return value;
          }, ifAbsent: () {
            List<String> list = [];
            list.add(image.key);
            return list;
          });
        }
      }
      updateCallback(TimelineEvent(TimelineMessageType.progress_upload,
          folderId: localCopy.folderID, data: MediaProgress(totalSize, sent)));
      print('sending: $totalSize');
      updateCallback(TimelineEvent(TimelineMessageType.syncing_story_state,
          folderId: localCopy.folderID, data: uploadingImages));

      for (int i = 0; i < localCopy.images.length; i++) {
        MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          var streamController = new StreamController<List<int>>();

          image.value.stream.listen((event) {
            sent += event.length;
            updateCallback(TimelineEvent(TimelineMessageType.progress_upload,
                folderId: localCopy.folderID,
                data: MediaProgress(totalSize, sent)));
            streamController.add(event);
          }, onDone: () {
            streamController.close();
          }, onError: (error) {
            print('error: $error');
            streamController.close();
          });

          await storage
              .uploadMediaToFolder(cloudCopy, image.key, image.value, 10,
                  streamController.stream)
              .then((imageID) {
            uploadingImages.update(localCopy.folderID, (value) {
              value.remove(image.key);
              return value;
            });
            updateCallback(TimelineEvent(
                TimelineMessageType.syncing_story_state,
                folderId: localCopy.folderID,
                data: uploadingImages));

            if (imageID != null) {
              imagesToAdd.putIfAbsent(imageID, () => image.value);
              localImagesToDelete.add(image.key);
            } else {
              print('imageID $imageID');
            }
            print('uploaded this image: ${image.key}');
          }, onError: (error) {
            print('error $error');
          });
        }
      }

      for (MapEntry<String, StoryMedia> image in cloudCopy.images.entries) {
        if (!localCopy.images.containsKey(image.key)) {
          print('delete this image: ${image.key}');
          tasks.add(storage.delete(image.key).then((value) {
            imagesToDelete.add(image.key);
          }, onError: (error) {
            print('error $error');
          }));
        }
      }
    }

    return Future.wait(tasks).then((_) {
      cloudCopy.images.addAll(imagesToAdd);
      localCopy.images.addAll(imagesToAdd);
      cloudCopy.images
          .removeWhere((key, value) => imagesToDelete.contains(key));
      localCopy.images
          .removeWhere((key, value) => localImagesToDelete.contains(key));
      imagesToAdd.forEach((key, value) {
        RetryService.getThumbnail(
            storage, localCopy.folderID, key, localCopy.images, uploadingImages,
            () {
          updateCallback(TimelineEvent(TimelineMessageType.syncing_story_state,
              folderId: localCopy.folderID, data: uploadingImages));
        });
      });
      RetryService.checkNeedsRefreshing(
          localCopy.folderID, uploadingImages, localCopy, () {
        updateCallback(TimelineEvent(TimelineMessageType.syncing_story_state,
            folderId: localCopy.folderID, data: uploadingImages));
      });
    });
  }

  Future<EventContent> createEventFolder(
      String parentId, int timestamp, bool mainEvent,
      {Function(TimelineEvent) updateCallback}) async {
    try {
      var folderID = await storage.createStory(parentId, timestamp);

      EventContent event = EventContent(
          comments: AdventureComments(comments: []),
          folderID: folderID,
          timestamp: timestamp,
          subEvents: [],
          images: Map());
      event.settingsID = await _uploadSettingsFile(folderID, event);

      if (mainEvent) {
        TimelineData timelineEvent =
            TimelineData(mainEvent: event, subEvents: []);
        event.commentsID = await _uploadCommentsFile(event, null);
        cloudStories.putIfAbsent(folderID, () => timelineEvent);
        localStories.putIfAbsent(
            folderID, () => TimelineData.clone(timelineEvent));
      }

      if (mainEvent) {
        updateCallback(TimelineEvent(TimelineMessageType.updated_stories));
      }
      return event;
    } catch (e) {
      print('error: $e');
    }
    return null;
  }

  Future<String> _uploadSettingsFile(
      String parentId, EventContent content) async {
    AdventureSettings settings = AdventureSettings(
        title: content.title,
        description: content.description,
        emoji: content.emoji);
    String jsonString = jsonEncode(settings);
    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    if (content.settingsID != null) {
      var folder = await storage.updateFile(
          null, content.settingsID, Media(mediaStream, fileContent.length));
      return folder.id;
    }

    var folderID = await storage.uploadMedia(
        parentId, Constants.SETTINGS_FILE, fileContent.length, mediaStream,
        mimeType: "application/json");
    return folderID;
  }

  Future<String> _uploadCommentsFile(
      EventContent event, AdventureComment comment) async {
    AdventureComments comments =
        AdventureComments.fromJson(await storage.getJsonFile(event.commentsID));
    if (comments == null) {
      comments = AdventureComments();
    }
    if (comments.comments == null) {
      comments.comments = [];
    }
    if (comment != null) {
      comments.comments.add(comment);
    }
    String jsonString = jsonEncode(comments);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    var folderID;
    if (event.commentsID == null) {
      folderID = await storage.uploadMedia(event.folderID,
          Constants.COMMENTS_FILE, fileContent.length, mediaStream,
          mimeType: "application/json");
    } else {
      var folder = await storage.updateFile(
          null, event.commentsID, Media(mediaStream, fileContent.length));
      folderID = folder.id;
    }

    event.comments = comments;
    return folderID;
  }
}
