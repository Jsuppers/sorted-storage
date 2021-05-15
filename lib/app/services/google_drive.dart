// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:emojis/emojis.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/folder_content.dart';

// Project imports:
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
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
      updatePosition.metadata[describeEnum(MetadataKeys.timestamp)] = order;
      await updateDescription(id, updatePosition.metadata);
    } else {
      throw 'error';
    }

    return order;
  }

  double? _getOrder(UpdatePosition updatePosition, int index) {
    if (updatePosition.media != null) {
      return updatePosition.items[index]?.folderMedia?.order as double?;
    }
    return updatePosition.items[index]?.order as double?;
  }

  String? _getId(UpdatePosition updatePosition, int index) {
    if (updatePosition.media != null) {
      return updatePosition.items[index]?.folderMedia?.id as String?;
    }
    return updatePosition.items[index]?.id as String?;
  }

  /// upload a data stream to a file, and return the file's id
  Future<String?> uploadMediaToFolder(String folderID, String imageName,
      FolderMedia storyMedia, Stream<List<int>> dataStream) async {
    final File mediaFile = File();
    mediaFile.parents = <String>[folderID];
    mediaFile.name = imageName;
    mediaFile.description = storyMedia.order.toString();

    final Media image = Media(dataStream, storyMedia.contentSize);
    final File uploadMedia =
        await driveApi!.files.create(mediaFile, uploadMedia: image);

    return uploadMedia.id;
  }

//  /// update a media file index
//  Future<File> _updatePosition(String imageID, dynamic position) async {
//    final File mediaFile = File();
//    mediaFile.description = position.toString();
//
//    return driveApi!.files.update(mediaFile, imageID);
//  }

  /// update a media file index
  Future<File> updateDescription(String fileId, Map<String, dynamic> metadata) async {
    final File mediaFile = File();
    mediaFile.description = jsonEncode(metadata);

    return driveApi!.files.update(mediaFile, fileId);
  }

  Future<FolderContent?> createStory(String? parentID) async {
    if (parentID == null) {
      return null;
    }
    final File fileMetadata = File();
    final FolderContent fileProperties = FolderContent(
        title: 'New Folder',
        emoji: Emojis.smilingFace);
    fileMetadata.name = '${Emojis.smilingFace} New Folder';
    fileMetadata.parents = <String>[parentID];
    fileMetadata.mimeType = 'application/vnd.google-apps.folder';
    fileMetadata.description = jsonEncode(fileProperties.metadata);
    final File rt = await createFile(fileMetadata);
    fileProperties.id = rt.id;

    return fileProperties;
  }
//
//  /// create a story (a folder with the timestamp as the name)
//  Future<String?> createStory(String parentID) async {
//    final File story = File();
//    story.parents = <String>[parentID];
//    story.mimeType = 'application/vnd.google-apps.folder';
//    story.name = timestamp.toString();
//
//    final File folder = await driveApi!.files.create(story);
//    return folder.id;
//  }

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
