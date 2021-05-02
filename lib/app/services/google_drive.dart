// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/update_position.dart';

/// service which communicates with google drive
class GoogleDrive {
  // ignore: public_member_api_docs
  GoogleDrive({this.driveApi});

  /// drive api
  DriveApi? driveApi;

  Future<double?> updatePosition(UpdatePosition updatePosition) async {
    double? order = _getOrder(updatePosition, updatePosition.currentIndex);

    if (updatePosition.targetIndex == updatePosition.items.length - 1) {
      order = DateTime.now().millisecondsSinceEpoch.toDouble();
    } else if (updatePosition.targetIndex == 0) {
      order = _getOrder(updatePosition, 0);
      if (order != null) {
        order -= 1;
      }
    } else {
      final double? orderAbove =
          _getOrder(updatePosition, updatePosition.targetIndex);
      final double? orderBelow =
          _getOrder(updatePosition, updatePosition.targetIndex + 1);
      if (orderAbove != null && orderBelow != null) {
        order = (orderAbove + orderBelow) / 2;
      }
    }
    final String? id = _getId(updatePosition, updatePosition.currentIndex);
    if (id != null) {
      await _updatePosition(id, order);
    } else {
      throw 'error';
    }

    return order;
  }

  double? _getOrder(UpdatePosition updatePosition, int index) {
    if (updatePosition.media != null) {
      return updatePosition.items[index]?.storyMedia?.order as double?;
    }
    return updatePosition.items[index]?.order as double?;
  }

  String? _getId(UpdatePosition updatePosition, int index) {
    if (updatePosition.media != null) {
      return updatePosition.items[index]?.storyMedia?.id as String?;
    }
    return updatePosition.items[index]?.id as String?;
  }

  /// upload a data stream to a file, and return the file's id
  Future<String?> uploadMediaToFolder(String folderID, String imageName,
      StoryMedia storyMedia, Stream<List<int>> dataStream) async {
    final File mediaFile = File();
    mediaFile.parents = <String>[folderID];
    mediaFile.name = imageName;
    mediaFile.description = storyMedia.order.toString();

    final Media image = Media(dataStream, storyMedia.contentSize);
    final File uploadMedia =
        await driveApi!.files.create(mediaFile, uploadMedia: image);

    return uploadMedia.id;
  }

  /// update a media file index
  Future<File> _updatePosition(String imageID, dynamic position) async {
    final File mediaFile = File();
    mediaFile.description = position.toString();

    return driveApi!.files.update(mediaFile, imageID);
  }

  /// read and return the contents of a json file
  Future<Map<String, dynamic>?> getJsonFile(String? fileId) async {
    Map<String, dynamic>? event;
    if (fileId != null) {
      final Media mediaFile = await driveApi!.files
          .get(fileId, downloadOptions: DownloadOptions.fullMedia) as Media;

      final List<int> dataStore = <int>[];
      await for (final List<int> data in mediaFile.stream) {
        dataStore.insertAll(dataStore.length, data);
      }
      event = jsonDecode(utf8.decode(dataStore)) as Map<String, dynamic>;
    }
    return event;
  }

  /// create a story (a folder with the timestamp as the name)
  Future<String?> createStory(String parentID, int timestamp) async {
    final File story = File();
    story.parents = <String>[parentID];
    story.mimeType = 'application/vnd.google-apps.folder';
    story.name = timestamp.toString();

    final File folder = await driveApi!.files.create(story);
    return folder.id;
  }

  Future<String?> uploadMedia(String parentID, String name, int contentLength,
      Stream<List<int>> mediaStream,
      {required String mimeType}) async {
    final File mediaFile = File();
    mediaFile.parents = <String>[parentID];
    mediaFile.mimeType = mimeType;
    mediaFile.name = name;
    final File folder = await driveApi!.files
        .create(mediaFile, uploadMedia: Media(mediaStream, contentLength));

    return folder.id;
  }

  Future<String?> updateFileName(String fileID, String name) async {
    try {
      final File eventToUpload = File();
      eventToUpload.name = name;

      final File folder = await driveApi!.files.update(eventToUpload, fileID);

      return folder.id;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> createFile(File request, {Media? media}) async {
    return driveApi!.files.create(request, uploadMedia: media);
  }

  Future<dynamic> delete(String fileID) async {
    return driveApi!.files.delete(fileID);
  }

  Future<dynamic> getFile(String fileID, {String? filter}) async {
    return driveApi!.files.get(fileID, $fields: filter);
  }

  Future<FileList> listFiles(String query, {String? filter}) async {
    return driveApi!.files.list(q: query, $fields: filter);
  }

  Future<File> updateFile(String fileID, Media media) {
    return driveApi!.files.update(File(), fileID, uploadMedia: media);
  }

  Future<Permission> createPermission(String fileID, Permission perm) async {
    return driveApi!.permissions.create(perm, fileID);
  }

  Future<PermissionList> listPermissions(String fileID) async {
    return driveApi!.permissions.list(fileID);
  }

  Future<dynamic> deletePermission(String fileID, String permissionID) async {
    return driveApi!.permissions.delete(fileID, permissionID);
  }
}
