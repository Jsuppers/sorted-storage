import 'dart:convert';

import 'package:googleapis/drive/v3.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class GoogleDrive {

  static Future<String> uploadMediaToFolder(DriveApi driveApi, EventContent eventContent,
      String imageName, StoryMedia storyMedia, int delayMilliseconds) async {
    print('converting to list');
    Stream<List<int>> dataStream;
    if (storyMedia.isImage) {
      dataStream = Future.value(storyMedia.bytes.toList()).asStream();
    }else {
      dataStream = storyMedia.stream;
    }

    File originalFileToUpload = File();
    originalFileToUpload.parents = [eventContent.folderID];
    originalFileToUpload.name = imageName;
    Media image = Media(dataStream, storyMedia.size);

    var uploadMedia = await driveApi.files
        .create(originalFileToUpload, uploadMedia: image);

    return uploadMedia.id;
  }

  static Future<dynamic> getJsonFile(DriveApi driveApi, String fileId) async {
    Map<String, dynamic> event;
    if (fileId != null) {
      Media mediaFile = await driveApi.files
          .get(fileId, downloadOptions: DownloadOptions.FullMedia);

      List<int> dataStore = [];
      await for (var data in mediaFile.stream) {
        dataStore.insertAll(dataStore.length, data);
      }
      event = jsonDecode(utf8.decode(dataStore));
    }
    return event;
  }

  static Future<String> createStory(DriveApi driveApi, String parentID, int timestamp) async {
    File eventToUpload = File();
    eventToUpload.parents = [parentID];
    eventToUpload.mimeType = "application/vnd.google-apps.folder";
    eventToUpload.name = timestamp.toString();

    var folder = await driveApi.files.create(eventToUpload);
    return folder.id;
  }


  static Future<String> uploadMedia(DriveApi driveApi, String parentID, String name, int contentLength, Stream<List<int>> mediaStream, {String mimeType}) async {
    File mediaFile = File();
    mediaFile.parents = [parentID];
    if (mimeType != null) {
      mediaFile.mimeType = mimeType;
    }
    mediaFile.name = name;
    var folder = await driveApi.files.create(mediaFile,
        uploadMedia: Media(mediaStream, contentLength));

    return folder.id;
  }

  static Future<String> getMediaFolder(DriveApi driveApi) async {
    try {
      String mediaFolderID;
      print('getting media folder');

      String query =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.ROOT_FOLDER}' and trashed=false";
      var folderPArent = await driveApi.files.list(q: query);
      String parentId;

      if (folderPArent.files.length == 0) {
        File fileMetadata = new File();
        fileMetadata.name = Constants.ROOT_FOLDER;
        fileMetadata.mimeType = "application/vnd.google-apps.folder";
        fileMetadata.description = "please don't modify this folder";
        var rt = await driveApi.files.create(fileMetadata);
        parentId = rt.id;
      } else {
        parentId = folderPArent.files.first.id;
      }

      String query2 =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.MEDIA_FOLDER}' and '$parentId' in parents and trashed=false";
      var folder = await driveApi.files.list(q: query2);

      if (folder.files.length == 0) {
        File fileMetadataMedia = new File();
        fileMetadataMedia.name = Constants.MEDIA_FOLDER;
        fileMetadataMedia.parents = [parentId];
        fileMetadataMedia.mimeType = "application/vnd.google-apps.folder";
        fileMetadataMedia.description = "please don't modify this folder";

        var folder = await driveApi.files.create(fileMetadataMedia);
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

  static Future<String> updateEventFolderTimestamp(
      DriveApi driveApi, String fileID, int timestamp) async {
    try {
      File eventToUpload = File();
      eventToUpload.name = timestamp.toString();

      var folder = await driveApi.files.update(eventToUpload, fileID);
      print('updated folder: $folder');

      return folder.id;
    } catch (e) {
      print('error: $e');
      return e.toString();
    }
  }

}