import 'dart:async';
import 'dart:convert';

import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/comments_response.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/constants.dart';

class GoogleDrive {
  DriveApi driveApi;

  GoogleDrive();

  setDrive(DriveApi driveApi) {
    this.driveApi = driveApi;
  }

  Future<String> uploadMediaToFolder(
      StoryContent eventContent,
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

    return uploadMedia.id as String;
  }

  Future<Map<String, dynamic>> getJsonFile(String fileId) async {
    Map<String, dynamic> event;
    if (fileId != null) {
      final mediaFile = await driveApi.files
          .get(fileId, downloadOptions: DownloadOptions.FullMedia);

      List<int> dataStore = [];
      await for (dynamic data in mediaFile.stream) {
        dataStore.insertAll(dataStore.length, data as Iterable<int>);
      }
      event = jsonDecode(utf8.decode(dataStore)) as Map<String, dynamic>;
    }
    return event;
  }

  Future<CommentsResponse> uploadCommentsFile(
      {String commentsID, String folderID, AdventureComment comment}) async {
    AdventureComments comments;
    if (commentsID != null) {
      comments = AdventureComments.fromJson(await getJsonFile(commentsID));
    }
    comments ??= AdventureComments();
    comments.comments ??= <AdventureComment>[];

    if (comment != null) {
      comments.comments.add(comment);
    }
    String jsonString = jsonEncode(comments);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    String responseID;
    if (commentsID == null) {
      responseID = await uploadMedia(
          folderID, Constants.COMMENTS_FILE, fileContent.length, mediaStream,
          mimeType: "application/json");
    } else {
      final File folder = await updateFile(
          null, commentsID, Media(mediaStream, fileContent.length));
      responseID = folder.id;
    }

    return CommentsResponse(comments: comments, commentsID: responseID);
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

  Future<File> createFile(File request, {Media media}) async {
    return driveApi.files.create(request, uploadMedia: media);
  }

  Future<dynamic> delete(String fileID) async {
    return driveApi.files.delete(fileID);
  }

  Future<dynamic> getFile(String fileID, {String filter}) async {
    return driveApi.files.get(fileID, $fields: filter);
  }

  Future<FileList> listFiles(String query, {String filter}) async {
    return driveApi.files.list(q: query, $fields: filter);
  }

  Future<File> updateFile(File request, String fileID, Media media) {
    return driveApi.files.update(request, fileID, uploadMedia: media);
  }

  Future<Permission> createPermission(String fileID, Permission perm) async {
    return driveApi.permissions.create(perm, fileID);
  }

  Future<PermissionList> listPermissions(String fileID) async {
    return driveApi.permissions.list(fileID);
  }

  Future<dynamic> deletePermission(String fileID, String permissionID) async {
    return driveApi.permissions.delete(fileID, permissionID);
  }
}
