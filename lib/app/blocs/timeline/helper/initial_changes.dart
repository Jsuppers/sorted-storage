import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class InitialChanges {
  GoogleDrive storage;
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;

  InitialChanges(this.storage, this.cloudStories, this.localStories);

  Stream<TimelineState> update(
      TimelineEvent event,
      Function(TimelineEvent) updateCallback,
      Function(String) mediaFolderIDUpdate,
      Function(Map<String, TimelineData>) cloudStoriesUpdate,
      Function(Map<String, TimelineData>) localStoriesUpdate) async* {
    if (event.type == TimelineMessageType.new_user) {
      mediaFolderIDUpdate(null);
      cloudStoriesUpdate(null);
      localStoriesUpdate(null);
      yield TimelineState(TimelineMessageType.initial_state, Map());
      return;
    }

    if (event.type == TimelineMessageType.retrieve_story ||
        event.type == TimelineMessageType.retrieve_stories) {
      _getStories(
          folderID: event.folderId,
          updateCallback: updateCallback,
          mediaFolderIDUpdate: mediaFolderIDUpdate,
          cloudStoriesUpdate: cloudStoriesUpdate,
          localStoriesUpdate: localStoriesUpdate);
      return;
    }
  }

  _getStories(
      {String folderID,
      Function(TimelineEvent) updateCallback,
      Function(String) mediaFolderIDUpdate,
      Function(Map<String, TimelineData>) cloudStoriesUpdate,
      Function(Map<String, TimelineData>) localStoriesUpdate}) {
    if (localStories == null) {
      localStories = Map();
      localStoriesUpdate(localStories);
    }
    if (cloudStories == null) {
      cloudStories = Map();
      cloudStoriesUpdate(cloudStories);
      if (folderID != null) {
        getViewEvent(folderID).then((value) =>
            updateCallback(TimelineEvent(TimelineMessageType.updated_stories)));
      } else {
        getMediaFolder().then((value) {
          mediaFolderIDUpdate(value);
          getEventsFromFolder(value).then((value) => updateCallback(
              TimelineEvent(TimelineMessageType.updated_stories)));
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

      print('media folder: $mediaFolderID');
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
