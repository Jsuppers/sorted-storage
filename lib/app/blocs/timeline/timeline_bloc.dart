import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;
  DriveApi driveApi;
  String mediaFolderID;

  TimelineBloc()
      : super(TimelineState(TimelineMessageType.initial_state, Map()));

  @override
  Stream<TimelineState> mapEventToState(event) async* {
    switch (event.type) {
      case TimelineMessageType.update_drive:
        driveApi = event.driveApi;
        break;
      case TimelineMessageType.retrieve_stories:
        _getStories();
        break;
      case TimelineMessageType.initial_state:
        throw Exception("unknown message");
        break;
      case TimelineMessageType.updated_stories:
        yield TimelineState(TimelineMessageType.updated_stories, localStories);
        break;
      case TimelineMessageType.create_story:
        _createEventFolder(mediaFolderID, event.timestamp, event.mainEvent);
        break;
      case TimelineMessageType.delete_story:
        yield TimelineState(
            TimelineMessageType.syncing_story_start, localStories,
            folderID: event.folderId);
        _deleteEvent(event.folderId);
        break;
      case TimelineMessageType.cancel_story:
        localStories[event.folderId] =
            TimelineData.clone(cloudStories[event.folderId]);
        localStories[event.folderId].locked = true;
        yield TimelineState(TimelineMessageType.cancel_story, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_story:
        localStories[event.folderId].locked = false;
        yield TimelineState(TimelineMessageType.edit_story, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.syncing_story_start:
        localStories[event.folderId].saving = true;
        _syncCopies(event.folderId);
        yield TimelineState(
            TimelineMessageType.syncing_story_start, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.syncing_story_end:
        localStories[event.folderId].saving = false;
        localStories[event.folderId].locked = true;
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.uploading_comments_start:
        TimelineData timelineEvent = cloudStories[event.folderId];
        _sendComment(timelineEvent.mainEvent, event.comment).then((value) {
          this.add(TimelineEvent(
              TimelineMessageType.uploading_comments_finished,
              folderId: event.folderId));
        });
        yield TimelineState(
            TimelineMessageType.uploading_comments_start, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.uploading_comments_finished:
        yield TimelineState(
            TimelineMessageType.uploading_comments_finished, localStories,
            folderID: event.folderId,
            comments: cloudStories[event.folderId].mainEvent.comments.comments);
        break;
      case TimelineMessageType.create_sub_story:
        var story = localStories[event.parentId];
        story.subEvents.add(EventContent(
          folderID: "temp_" +
              event.parentId +
              "_" +
              story.subEvents.length.toString(),
          timestamp: story.mainEvent.timestamp,
          images: Map(),
          comments: AdventureComments(comments: List()),
          subEvents: List(),
        ));
        print('sub story! ');
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.delete_sub_story:
        var story = localStories[event.parentId];
        story.subEvents
            .removeWhere((element) => element.folderID == event.folderId);
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.delete_image:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.images.remove(event.imageKey);
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_description:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.description = event.text;
        break;
      case TimelineMessageType.edit_title:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.title = event.text;
        break;
      case TimelineMessageType.add_image:
        var eventContent = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        FilePickerResult file;
        try {
          file = await FilePicker.platform.pickFiles(
              type: FileType.media, allowMultiple: true, withReadStream: true);
        } catch (e) {
          print(e);
          return;
        }
        if (file == null || file.files == null || file.files.length == 0) {
          return;
        }
        for (int i = 0; i < file.files.length; i++) {
          PlatformFile element = file.files[i];
          String mime = lookupMimeType(element.name);
          eventContent.images.putIfAbsent(
              element.name,
              () => StoryMedia(
                  stream: element.readStream,
                  size: element.size,
                  isVideo: mime.startsWith("video/"),
                  isDocument: !mime.startsWith("video/") &&
                      !mime.startsWith("image/")));
        }
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_timestamp:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.timestamp = event.timestamp;
        break;
      case TimelineMessageType.syncing_story_state:
        yield TimelineState(
            TimelineMessageType.syncing_story_state, localStories,
            folderID: event.folderId, uploadingImages: event.uploadingImages);
        break;
      case TimelineMessageType.retrieve_story:
        _getStories(folderID: event.folderId);
        break;
      case TimelineMessageType.edit_emoji:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.emoji = event.text;
        yield TimelineState(TimelineMessageType.edit_emoji, localStories,
            folderID: event.folderId, data: event.text);
        break;
      case TimelineMessageType.progress_upload:
        yield TimelineState(TimelineMessageType.progress_upload, localStories,
            folderID: event.folderId, data: event.data);
        break;
    }
  }

  _getStories({String folderID}) {
    if (localStories == null) {
      localStories = Map();
    }
    if (cloudStories == null) {
      cloudStories = Map();

      if (folderID != null) {
        _getViewEvent(folderID);
      } else {
        GoogleDrive.getMediaFolder(driveApi).then((value) {
          mediaFolderID = value;
          _getEventsFromFolder(mediaFolderID);
        });
      }
    }
  }

  Future<TimelineData> _getViewEvent(String folderID) async {
    var folder = await driveApi.files.get(folderID);
    if (folder == null) {
      return null;
    }
    int timestamp = int.tryParse(folder.name);
    if (timestamp == null) {
      return null;
    }
    var mainEvent = await _createEventFromFolder(folderID, timestamp);

    List<EventContent> subEvents = List();
    for (SubEvent subEvent in mainEvent.subEvents) {
      subEvents
          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
    }
    var timelineData = TimelineData(mainEvent: mainEvent, subEvents: subEvents);
    localStories.putIfAbsent(folderID, () => timelineData);
    cloudStories.putIfAbsent(folderID, () => TimelineData.clone(timelineData));

    this.add(TimelineEvent(TimelineMessageType.updated_stories));
  }

  Future _deleteEvent(fileId) async {
    driveApi.files.delete(fileId).then((value) {
      cloudStories.remove(fileId);
      localStories.remove(fileId);
      this.add(TimelineEvent(TimelineMessageType.updated_stories));
    });
  }

  Future _getEventsFromFolder(String folderID) async {
    try {
      print('getting event: $folderID');
      FileList eventList = await driveApi.files.list(
          q: "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");
      List<String> folderIds = [];
      print('getting event: ${eventList.files}');
      for (File file in eventList.files) {
        int timestamp = int.tryParse(file.name);

        if (timestamp != null) {
          folderIds.add(file.id);
          _createEventFromFolder(file.id, timestamp).then((mainEvent) async {
            List<EventContent> subEvents = List();
            for (SubEvent subEvent in mainEvent.subEvents) {
              subEvents.add(await _createEventFromFolder(
                  subEvent.id, subEvent.timestamp));
            }

            TimelineData data =
                TimelineData(mainEvent: mainEvent, subEvents: subEvents);
            cloudStories.putIfAbsent(file.id, () => data);
            localStories.putIfAbsent(file.id, () => TimelineData.clone(data));
          });
        }
      }
      await _waitUntil(() => cloudStories.length == folderIds.length,
          Duration(milliseconds: 500));

      this.add(TimelineEvent(TimelineMessageType.updated_stories));
    } catch (e) {
      print('error: $e');
    } finally {}
  }

  Future<EventContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    FileList filesInFolder = await driveApi.files.list(
        q: "'$folderID' in parents and trashed=false",
        $fields: 'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink)');

    String settingsID;
    String commentsID;
    Map<String, StoryMedia> images = Map();
    List<SubEvent> subEvents = List();
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

    AdventureSettings settings = AdventureSettings.fromJson(
        await GoogleDrive.getJsonFile(driveApi, settingsID));

    AdventureComments comments = AdventureComments.fromJson(
        await GoogleDrive.getJsonFile(driveApi, commentsID));

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

  Future _waitUntil(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  Future<EventContent> _createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
    try {
      var folderID =
          await GoogleDrive.createStory(driveApi, parentId, timestamp);

      EventContent event = EventContent(
          comments: AdventureComments(comments: List()),
          folderID: folderID,
          timestamp: timestamp,
          subEvents: List(),
          images: Map());
      event.settingsID = await _uploadSettingsFile(folderID, event);

      if (mainEvent) {
        TimelineData timelineEvent =
            TimelineData(mainEvent: event, subEvents: []);
        cloudStories.putIfAbsent(folderID, () => timelineEvent);
        localStories.putIfAbsent(
            folderID, () => TimelineData.clone(timelineEvent));
        await _uploadCommentsFile(event, null);
      }

      if (mainEvent) {
        this.add(TimelineEvent(TimelineMessageType.updated_stories));
      }
      return event;
    } catch (e) {
      print('error: $e');
    }
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
      var folder = await driveApi.files.update(null, content.settingsID,
          uploadMedia: Media(mediaStream, fileContent.length));
      return folder.id;
    }

    var folderID = await GoogleDrive.uploadMedia(driveApi, parentId,
        Constants.SETTINGS_FILE, fileContent.length, mediaStream,
        mimeType: "application/json");
    return folderID;
  }

  Future<String> _uploadCommentsFile(
      EventContent event, AdventureComment comment) async {
    AdventureComments comments = AdventureComments.fromJson(
        await GoogleDrive.getJsonFile(driveApi, event.commentsID));
    if (comments == null) {
      comments = AdventureComments();
    }
    if (comments.comments == null) {
      comments.comments = List();
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
      folderID = await GoogleDrive.uploadMedia(driveApi, event.folderID,
          Constants.COMMENTS_FILE, fileContent.length, mediaStream,
          mimeType: "application/json");
    } else {
      var folder = await driveApi.files.update(null, event.commentsID,
          uploadMedia: Media(mediaStream, fileContent.length));
      folderID = folder.id;
    }

    event.comments = comments;
    event.commentsID = folderID;
    return folderID;
  }

  Future _sendComment(EventContent event, AdventureComment comment) async {
    AdventureComments comments = AdventureComments.fromJson(
        await GoogleDrive.getJsonFile(driveApi, event.commentsID));
    if (comments == null) {
      comments = AdventureComments();
    }
    if (comments.comments == null) {
      comments.comments = List();
    }
    if (comment != null) {
      comments.comments.add(comment);
    }

    File eventToUpload = File();
    eventToUpload.parents = [event.folderID];
    eventToUpload.mimeType = "application/json";
    eventToUpload.name = Constants.COMMENTS_FILE;

    String jsonString = jsonEncode(comments);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    var folder;
    if (event.commentsID == null) {
      folder = await driveApi.files.create(eventToUpload,
          uploadMedia: Media(mediaStream, fileContent.length));
      Permission anyone = Permission();
      anyone.type = "anyone";
      anyone.role = "writer";

      await driveApi.permissions.create(anyone, folder.id);
    } else {
      folder = await driveApi.files.update(null, event.commentsID,
          uploadMedia: Media(mediaStream, fileContent.length));
    }

    event.comments = comments;
    event.commentsID = folder.id;
    return folder.id;
  }

  _syncCopies(String eventFolderID) async {
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
            await _createEventFolder(eventFolderID, subEvent.timestamp, false);
        cloudCopy.subEvents.add(cloudSubEvent);
        subEvent.folderID = cloudSubEvent.folderID;
        subEvent.settingsID = cloudSubEvent.settingsID;
      } else {
        cloudSubEvent = cloudCopy.subEvents
            .singleWhere((element) => element.folderID == subEvent.folderID);
      }

      await _syncContent(subEvent, cloudSubEvent);
    }

    List<EventContent> eventsToDelete = List();
    for (EventContent subEvent in cloudCopy.subEvents) {
      EventContent localEvent;
      for (int i = 0; i < localCopy.subEvents.length; i++) {
        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
          localEvent = localCopy.subEvents[i];
          break;
        }
      }
      if (localEvent == null) {
        await driveApi.files.delete(subEvent.folderID);
        eventsToDelete.add(subEvent);
      }
    }

    for (EventContent subEvent in eventsToDelete) {
      cloudCopy.subEvents.remove(subEvent);
    }

    await _syncContent(localCopy.mainEvent, cloudCopy.mainEvent);
    localCopy = TimelineData.clone(cloudCopy);

    this.add(TimelineEvent(TimelineMessageType.syncing_story_end,
        folderId: eventFolderID));
    if (rebuildAllStories) {
      this.add(TimelineEvent(TimelineMessageType.updated_stories));
    }
  }

  Future _syncContent(EventContent localCopy, EventContent cloudCopy) async {
    List<Future> tasks = List();
    Map<String, List<String>> uploadingImages = Map();

    print('updating cloud storage');
    if (localCopy.timestamp != cloudCopy.timestamp) {
      tasks.add(GoogleDrive.updateEventFolderTimestamp(
              driveApi, localCopy.folderID, localCopy.timestamp)
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
    tasks = List();
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
            List<String> list = List();
            list.add(image.key);
            return list;
          });
        }
      }
      this.add(TimelineEvent(TimelineMessageType.progress_upload,
          folderId: localCopy.folderID, data: MediaProgress(totalSize, sent)));
      print('sending: $totalSize');
      this.add(TimelineEvent(TimelineMessageType.syncing_story_state,
          folderId: localCopy.folderID, uploadingImages: uploadingImages));

      for (int i = 0; i < localCopy.images.length; i++) {
        MapEntry<String, StoryMedia> image =
            localCopy.images.entries.elementAt(i);
        if (!cloudCopy.images.containsKey(image.key)) {
          var streamController = new StreamController<List<int>>();

          image.value.stream.listen((event) {
            sent += event.length;
            this.add(TimelineEvent(TimelineMessageType.progress_upload,
                folderId: localCopy.folderID,
                data: MediaProgress(totalSize, sent)));
            streamController.add(event);
          }, onDone: () {
            streamController.close();
          }, onError: (error) {
            print('error: $error');
            streamController.close();
          });

          await GoogleDrive.uploadMediaToFolder(driveApi, cloudCopy, image.key,
                  image.value, 10, streamController.stream)
              .then((imageID) {
            uploadingImages.update(localCopy.folderID, (value) {
              value.remove(image.key);
              return value;
            });
            this.add(TimelineEvent(TimelineMessageType.syncing_story_state,
                folderId: localCopy.folderID,
                uploadingImages: uploadingImages));

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
          tasks.add(driveApi.files.delete(image.key).then((value) {
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
        getThumbnail(
            localCopy.folderID, key, localCopy.images, uploadingImages);
      });
      print(localCopy.images.toString());
      print(cloudCopy.images.toString());
      checkNeedsRefreshing(localCopy.folderID, uploadingImages, localCopy);
    });
  }

  void checkNeedsRefreshing(String folderID,
      Map<String, List<String>> uploadingImages, EventContent localCopy,
      {int maxTries = 60}) {
    if (maxTries == 0) {
      return;
    }
    print(maxTries);
    Future.delayed(Duration(seconds: 10), () async {
      for (MapEntry entry in localCopy.images.entries) {
        if (entry.value.thumbnailURL == null) {
          print("still waiting for a thumbnail: ${entry.key}");
          checkNeedsRefreshing(folderID, uploadingImages, localCopy,
              maxTries: maxTries - 1);
          return;
        }
      }
      this.add(TimelineEvent(TimelineMessageType.syncing_story_state,
          folderId: localCopy.folderID, uploadingImages: uploadingImages));
    });
  }

  void getThumbnail(String folderID, String imageKey,
      Map<String, StoryMedia> images, Map<String, List<String>> uploadingImages,
      {int maxTries = 10}) {
    int exp = 10;
    if (maxTries > exp) {
      maxTries = 10;
    }
    if (maxTries == 0) {
      return;
    }
    Future.delayed(Duration(seconds: (exp - maxTries) * 2), () async {
      if (images == null || !images.containsKey(imageKey)) {
        print('images $images');
        return;
      }

      File mediaFile = await driveApi.files
          .get(imageKey, $fields: 'id,hasThumbnail,thumbnailLink');

      if (mediaFile.hasThumbnail) {
        print(
            "thumbnail for image: $imageKey has been created! ${mediaFile.thumbnailLink}");
        images[imageKey].imageURL = mediaFile.thumbnailLink;
        this.add(TimelineEvent(TimelineMessageType.syncing_story_state,
            folderId: folderID, uploadingImages: uploadingImages));
        return;
      }

      print("waiting for a thumbnail for image: $imageKey");
      getThumbnail(folderID, imageKey, images, uploadingImages,
          maxTries: maxTries - 1);
    });
  }
}
