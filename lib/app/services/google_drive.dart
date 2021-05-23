// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:emojis/emojis.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/models/update_position.dart';

/// service which communicates with google drive
class GoogleDrive {
  // ignore: public_member_api_docs
  GoogleDrive({this.driveApi});

  /// drive api
  DriveApi? driveApi;

  static String folderFilter =
      'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description,owners)';

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
      await updateMetadata(id, updatePosition.metadata);
    } else {
      throw 'error';
    }

    return order;
  }

  double? _getOrder(UpdatePosition updatePosition, int index) {
    if (updatePosition.media != null) {
      return updatePosition.items[index]?.folderMedia?.getTimestamp()
          as double?;
    }
    return updatePosition.items[index]?.getTimestamp() as double?;
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
    mediaFile.description = jsonEncode(storyMedia.metadata ?? {});

    final Media image = Media(dataStream, storyMedia.contentSize);
    final File uploadMedia =
        await driveApi!.files.create(mediaFile, uploadMedia: image);

    return uploadMedia.id;
  }

  Future<File> updateMetadata(
      String fileId, Map<String, dynamic> metadata) async {
    final File mediaFile = File();
    mediaFile.description = jsonEncode(metadata);

    return driveApi!.files.update(mediaFile, fileId);
  }

  Future<Folder?> createFolder(Folder? parent) async {
    if (parent == null || parent.id == null) {
      return null;
    }
    final File fileMetadata = File();
    final Folder fileProperties = Folder(
        title: 'New Folder',
        emoji: Emojis.smilingFace,
        parent: parent,
        amOwner: true);
    fileMetadata.name = '${Emojis.smilingFace} New Folder';
    fileMetadata.parents = <String>[parent.id!];
    fileMetadata.mimeType = 'application/vnd.google-apps.folder';
    fileMetadata.description = jsonEncode(fileProperties.metadata ?? {});
    final File rt = await createFile(fileMetadata);
    fileProperties.id = rt.id;
    parent.subFolders!.add(fileProperties);

    return fileProperties;
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

  Future<bool> amOwner(String fileID) async {
    final File file = await getFile(fileID, filter: 'owners') as File;
    if (file.owners != null) {
      for (final User user in file.owners!) {
        if (user.me == true) {
          return true;
        }
      }
    }
    return false;
  }

  Future<FileList> listFiles(String query, {String? filter}) async {
    return driveApi!.files.list(q: query, $fields: filter);
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
