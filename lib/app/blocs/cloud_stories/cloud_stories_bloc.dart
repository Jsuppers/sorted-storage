import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CloudStoriesBloc extends Bloc<CloudStoriesEvent, CloudStoriesState> {
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;
  GoogleDrive storage;
  String mediaFolderID;

  CloudStoriesBloc({this.localStories, this.storage})
      : super(CloudStoriesState(CloudStoriesType.initial_state, null));

  @override
  Stream<CloudStoriesState> mapEventToState(event) async* {
    if (event.type == CloudStoriesType.new_user) {
      mediaFolderID = null;
      cloudStories = null;
      localStories.clear();
      yield CloudStoriesState(CloudStoriesType.initial_state, cloudStories);
      return;
    }

    if (event.type == CloudStoriesType.retrieve_story ||
        event.type == CloudStoriesType.retrieve_stories) {
      _getStories(folderID: event.folderId);
      return;
    }

    switch (event.type) {
      case CloudStoriesType.delete_story:
        yield CloudStoriesState(
            CloudStoriesType.syncing_story_start, cloudStories,
            folderID: event.folderId);
        _deleteEvent(event.folderId);
        break;
      case CloudStoriesType.syncing_story_start:
        localStories[event.folderId].saving = true;
        syncCopies(event.folderId);
        yield CloudStoriesState(
            CloudStoriesType.syncing_story_start, cloudStories,
            folderID: event.folderId);
        break;
      case CloudStoriesType.create_story:
        createEventFolder(mediaFolderID, event.data, event.mainEvent);
        break;
      case CloudStoriesType.updated_stories:
        yield CloudStoriesState(CloudStoriesType.updated_stories, cloudStories);
        break;
      case CloudStoriesType.syncing_story_end:
        localStories[event.folderId].saving = false;
        localStories[event.folderId].locked = true;
        yield CloudStoriesState(
            CloudStoriesType.syncing_story_end, cloudStories,
            folderID: event.folderId);
        break;
      case CloudStoriesType.syncing_story_state:
        yield CloudStoriesState(
            CloudStoriesType.syncing_story_state, cloudStories,
            folderID: event.folderId, data: event.data);
        break;
      case CloudStoriesType.progress_upload:
        yield CloudStoriesState(CloudStoriesType.progress_upload, cloudStories,
            folderID: event.folderId, data: event.data);
        break;
      default:
        break;
    }
  }

  Future _deleteEvent(fileId) async {
    storage.delete(fileId).then((value) {
      cloudStories.remove(fileId);
      localStories.remove(fileId);
      this.add(CloudStoriesEvent(CloudStoriesType.updated_stories));
    });
  }

  Future syncCopies(String eventFolderID) async {
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

      await _syncContent(subEvent, cloudSubEvent);
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

    await _syncContent(localCopy.mainEvent, cloudCopy.mainEvent);
    localCopy = TimelineData.clone(cloudCopy);

    this.add(CloudStoriesEvent(CloudStoriesType.syncing_story_end,
        folderId: eventFolderID));

    if (rebuildAllStories) {
      this.add(CloudStoriesEvent(CloudStoriesType.updated_stories,
          folderId: eventFolderID));
    }
  }

  Future _syncContent(EventContent localCopy, EventContent cloudCopy) async {
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

      this.add(CloudStoriesEvent(CloudStoriesType.progress_upload,
          folderId: localCopy.folderID, data: MediaProgress(totalSize, sent)));
      print('sending: $totalSize');
      this.add(CloudStoriesEvent(CloudStoriesType.syncing_story_state,
          folderId: localCopy.folderID, data: uploadingImages));

      for (int i = 0; i < localCopy.images.length; i++) {
        MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          var streamController = new StreamController<List<int>>();

          image.value.stream.listen((event) {
            sent += event.length;
            this.add(CloudStoriesEvent(CloudStoriesType.progress_upload,
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
            this.add(CloudStoriesEvent(CloudStoriesType.syncing_story_state,
                folderId: localCopy.folderID, data: uploadingImages));

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
          this.add(CloudStoriesEvent(CloudStoriesType.syncing_story_state,
              folderId: localCopy.folderID, data: uploadingImages));
        });
      });
      RetryService.checkNeedsRefreshing(
          localCopy.folderID, uploadingImages, localCopy, () {
        this.add(CloudStoriesEvent(CloudStoriesType.syncing_story_state,
            folderId: localCopy.folderID, data: uploadingImages));
      });
    });
  }

  Future<EventContent> createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
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
        var commentsResponse =
            await storage.uploadCommentsFile(folderID: event.folderID);
        event.comments = commentsResponse.comments;
        event.commentsID = commentsResponse.commentsID;
        TimelineData timelineEvent =
            TimelineData(mainEvent: event, subEvents: []);
        cloudStories.putIfAbsent(folderID, () => timelineEvent);
        localStories.putIfAbsent(
            folderID, () => TimelineData.clone(timelineEvent));
      }

      if (mainEvent) {
        this.add(CloudStoriesEvent(CloudStoriesType.updated_stories));
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

  _getStories({String folderID}) {
    if (cloudStories == null) {
      cloudStories = Map();
      if (folderID != null) {
        getViewEvent(folderID).then((value) =>
            this.add(CloudStoriesEvent(CloudStoriesType.updated_stories)));
      } else {
        getMediaFolder().then((value) {
          mediaFolderID = value;
          getEventsFromFolder(value).then((value) =>
              this.add(CloudStoriesEvent(CloudStoriesType.updated_stories)));
        });
      }
    }
  }

  Future getEventsFromFolder(String folderID) async {
    try {
      FileList eventList = await storage.listFiles(
          "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");
      List<String> folderIds = [];
      List<Future> tasks = [];
      for (File file in eventList.files) {
        int timestamp = int.tryParse(file.name);

        if (timestamp != null) {
          folderIds.add(file.id);
          tasks.add(_createEventFromFolder(file.id, timestamp)
              .then((mainEvent) async {
            List<EventContent> subEvents = [];
            for (SubEvent subEvent in mainEvent.subEvents) {
              subEvents.add(await _createEventFromFolder(
                  subEvent.id, subEvent.timestamp));
            }

            TimelineData data =
                TimelineData(mainEvent: mainEvent, subEvents: subEvents);
            cloudStories.putIfAbsent(file.id, () => data);
            localStories.putIfAbsent(file.id, () => TimelineData.clone(data));
          }));
        }
      }
      await Future.wait(tasks);
    } catch (e) {
      print('error: $e');
    } finally {}
  }

  Future getViewEvent(String folderID) async {
    var folder = await storage.getFile(folderID);
    if (folder == null) {
      return null;
    }
    int timestamp = int.tryParse(folder.name);
    if (timestamp == null) {
      return null;
    }
    var mainEvent = await _createEventFromFolder(folderID, timestamp);

    List<EventContent> subEvents = [];
    for (SubEvent subEvent in mainEvent.subEvents) {
      subEvents
          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
    }
    var timelineData = TimelineData(mainEvent: mainEvent, subEvents: subEvents);
    localStories.putIfAbsent(folderID, () => timelineData);
    cloudStories.putIfAbsent(folderID, () => TimelineData.clone(timelineData));
  }

  Future<String> getMediaFolder() async {
    try {
      String mediaFolderID;
      print('getting media folder');

      String query =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.ROOT_FOLDER}' and trashed=false";
      var folderPArent = await storage.listFiles(query);
      String parentId;

      if (folderPArent.files.length == 0) {
        File fileMetadata = new File();
        fileMetadata.name = Constants.ROOT_FOLDER;
        fileMetadata.mimeType = "application/vnd.google-apps.folder";
        fileMetadata.description = "please don't modify this folder";
        var rt = await storage.createFile(fileMetadata);
        parentId = rt.id;
      } else {
        parentId = folderPArent.files.first.id;
      }

      String query2 =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.MEDIA_FOLDER}' and '$parentId' in parents and trashed=false";
      var folder = await storage.listFiles(query2);

      if (folder.files.length == 0) {
        File fileMetadataMedia = new File();
        fileMetadataMedia.name = Constants.MEDIA_FOLDER;
        fileMetadataMedia.parents = [parentId];
        fileMetadataMedia.mimeType = "application/vnd.google-apps.folder";
        fileMetadataMedia.description = "please don't modify this folder";

        var folder = await storage.createFile(fileMetadataMedia);
        mediaFolderID = folder.id;
      } else {
        mediaFolderID = folder.files.first.id;
      }

      print('found media folder: $mediaFolderID');
      return mediaFolderID;
    } catch (e) {
      print('error: $e');
      return e.toString();
    } finally {}
  }

  Future<EventContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter: 'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink)');

    String settingsID;
    String commentsID;
    Map<String, StoryMedia> images = Map();
    List<SubEvent> subEvents = [];
    for (File file in filesInFolder.files) {
      if (file.mimeType.startsWith("image/") ||
          file.mimeType.startsWith("video/")) {
        StoryMedia media = StoryMedia();
        media.isVideo = file.mimeType.startsWith("video/");
        if (file.hasThumbnail) {
          media.imageURL = file.thumbnailLink;
        }
        images.putIfAbsent(file.id, () => media);
      } else if (file.name == Constants.SETTINGS_FILE) {
        settingsID = file.id;
      } else if (file.name == Constants.COMMENTS_FILE) {
        commentsID = file.id;
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        int timestamp = int.tryParse(file.name);
        if (timestamp != null) {
          subEvents.add(SubEvent(file.id, timestamp));
        }
      } else {
        StoryMedia media = StoryMedia();
        media.isDocument = true;
        if (file.hasThumbnail) {
          media.imageURL = file.thumbnailLink;
        }
        images.putIfAbsent(file.id, () => media);
      }
    }

    AdventureSettings settings =
        AdventureSettings.fromJson(await storage.getJsonFile(settingsID));

    AdventureComments comments =
        AdventureComments.fromJson(await storage.getJsonFile(commentsID));

    return EventContent(
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
