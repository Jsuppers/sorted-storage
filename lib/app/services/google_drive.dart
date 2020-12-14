import 'dart:async';
import 'dart:convert';

import 'package:googleapis/drive/v3.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class GoogleDrive {
  final DriveApi driveApi;

  GoogleDrive(this.driveApi);

  Future<String> uploadMediaToFolder(
      EventContent eventContent,
      String imageName,
      StoryMedia storyMedia,
      int delayMilliseconds,
      Stream<List<int>> dataStream) async {
    File mediaFile = File();
    mediaFile.parents = [eventContent.folderID];
    mediaFile.name = imageName;

    Media image = Media(dataStream, storyMedia.size);
    var uploadMedia;
    try {
      uploadMedia = await driveApi.files.create(mediaFile, uploadMedia: image);
    } catch (e) {}

    return uploadMedia.id;
  }

  Future<dynamic> getJsonFile(String fileId) async {
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

  Future<String> createStory(String parentID, int timestamp) async {
    File eventToUpload = File();
    eventToUpload.parents = [parentID];
    eventToUpload.mimeType = "application/vnd.google-apps.folder";
    eventToUpload.name = timestamp.toString();

    var folder = await driveApi.files.create(eventToUpload);
    return folder.id;
  }

  Future<String> uploadMedia(String parentID, String name, int contentLength,
      Stream<List<int>> mediaStream,
      {String mimeType}) async {
    File mediaFile = File();
    mediaFile.parents = [parentID];
    if (mimeType != null) {
      mediaFile.mimeType = mimeType;
    }
    mediaFile.name = name;
    var folder = await driveApi.files
        .create(mediaFile, uploadMedia: Media(mediaStream, contentLength));

    return folder.id;
  }


  Future<String> updateEventFolderTimestamp(
      String fileID, int timestamp) async {
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

  Future createFile(File request, {Media media}) async {
    return driveApi.files.create(request, uploadMedia: media);
  }

  Future delete(String fileID) async {
    return driveApi.files.delete(fileID);
  }

  Future getFile(String fileID, {String filter}) async {
    return driveApi.files.get(fileID, $fields: filter);
  }

  Future listFiles(String query, {String filter}) async {
    return driveApi.files.list(q: query, $fields: filter);
  }

  Future updateFile(File request, String fileID, Media media) {
    return driveApi.files.update(request, fileID, uploadMedia: media);
  }

  Future createPermission(String fileID, Permission permission) async {
    return driveApi.permissions.create(permission, fileID);
  }
}
