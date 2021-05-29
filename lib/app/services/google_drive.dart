// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:emojis/emojis.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/constants.dart';

/// service which communicates with google drive
class GoogleDrive {
  // ignore: public_member_api_docs
  GoogleDrive({this.driveApi});

  /// drive api
  DriveApi? driveApi;

  static const String _folderMimeType = 'application/vnd.google-apps.folder';
  static const String _folderFilter =
      'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description,owners)';
  static const String _rootFolderQuery =
      "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.rootFolder}' and trashed=false";

  Future<double?> updatePosition(UpdatePosition updatePosition) async {
    final double? order = await updatePosition.getCurrentItemPosition();
    final String? id = updatePosition.getCurrentItemId();
    if (id != null) {
      final Map<String, dynamic> metaData =
          updatePosition.getCurrentItemMetadata();
      metaData[describeEnum(MetadataKeys.timestamp)] = order;
      await updateMetadata(id, metaData);
    } else {
      throw 'error';
    }
    return order;
  }

  /// upload a data stream to a file, and return the file's id
  Future<String?> uploadMediaToFolder(String folderID, String imageName,
      FileData fileData, Stream<List<int>> dataStream) async {
    final File file = _createDriveFile(folderID,
        name: imageName, metadata: fileData.metadata);
    final Media image = Media(dataStream, fileData.contentSize);
    final File uploadedFile =
        await driveApi!.files.create(file, uploadMedia: image);

    return uploadedFile.id;
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
    final Folder folder = Folder(
        title: 'New Folder',
        emoji: Emojis.smilingFace,
        parent: parent,
        amOwner: true);
    final File file = _createDriveFile(parent.id!,
        mimeType: _folderMimeType, metadata: folder.metadata);
    final File rt = await driveApi!.files.create(file);
    folder.id = rt.id;
    parent.subFolders.add(folder);

    return folder;
  }

  Future<String?> updateFileName(String fileID, String name) async {
    final File file = File();
    file.name = name;
    final File folder = await driveApi!.files.update(file, fileID);
    return folder.id;
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

  Future<Folder> getRootFolder() async {
    final FileList folderParent =
        await listFiles(_rootFolderQuery, filter: GoogleDrive._folderFilter);
    File rootFile;
    Map<String, dynamic> metadata = <String, dynamic>{};
    if (folderParent.files!.isEmpty) {
      metadata.setTimestamp(DateTime.now().millisecondsSinceEpoch.toDouble());
      final File file = _createDriveFile(
        Constants.rootFolder,
        mimeType: _folderMimeType,
        metadata: metadata,
      );
      rootFile = await driveApi!.files.create(file);
    } else {
      rootFile = folderParent.files!.first;
      metadata = MetaData.fromString(rootFile.description);
    }
    final Folder rootFolder =
        await getFolder(rootFile.id!, folderName: rootFile.name!);
    rootFolder.metadata = metadata;
    rootFolder.isRootFolder = true;
    return rootFolder;
  }

  Future<Folder> updateFolder(String folderID,
      {String? folderName, required Folder folder}) async {
    if (folder.loaded == true) {
      return folder;
    }
    return _updateFolder(folder);
  }

  Future<Folder> getFolder(String folderID, {String? folderName}) async {
    final Folder folder =
        Folder.createFromFolderName(folderName: folderName, id: folderID);
    return _updateFolder(folder);
  }

  Future<Folder> _updateFolder(Folder folder) async {
    final String folderQuery = "'${folder.id}' in parents and trashed=false";
    final FileList filesInFolder =
        await listFiles(folderQuery, filter: GoogleDrive._folderFilter);
    final Map<String, FileData> files = <String, FileData>{};
    final List<Folder> subFolders = <Folder>[];
    int index = 0;
    for (final File file in filesInFolder.files!) {
      final Map<String, dynamic> metadata =
          MetaData.fromString(file.description);
      metadata.setTimestampIfEmpty(
          (DateTime.now().millisecondsSinceEpoch + index).toDouble());
      final bool subFolderOwner = _getAmOwner(file);

      if (file.mimeType!.startsWith('image/') ||
          file.mimeType!.startsWith('video/')) {
        final FileData media = FileData(
          id: file.id!,
          name: file.name!,
          isVideo: file.mimeType!.startsWith('video/'),
          retrieveThumbnail: true,
          thumbnailURL: file.thumbnailLink,
          metadata: metadata,
        );
        files.putIfAbsent(file.id!, () => media);
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final Folder subFolder = Folder.createFromFolderName(
            folderName: file.name!,
            owner: subFolderOwner,
            parent: folder,
            id: file.id!,
            metadata: metadata);
        subFolders.add(subFolder);
      } else {
        final FileData media = FileData(
            name: file.name!,
            id: file.id!,
            isDocument: true,
            thumbnailURL: file.thumbnailLink,
            retrieveThumbnail: true,
            metadata: metadata);
        files.putIfAbsent(file.id!, () => media);
      }
      index++;
    }

    folder.metadata
        .setTimestampIfEmpty(DateTime.now().millisecondsSinceEpoch.toDouble());
    folder.files = files;
    folder.subFolders = subFolders;
    folder.loaded = true;
    folder.amOwner ??= await amOwner(folder.id!);

    return folder;
  }

  bool _getAmOwner(File file) {
    if (file.owners != null) {
      for (final User user in file.owners!) {
        if (user.me == true) {
          return true;
        }
      }
    }
    return false;
  }

  File _createDriveFile(
    String parentID, {
    String? name,
    String? mimeType,
    Map<String, dynamic>? metadata,
  }) {
    final File file = File();
    file.name = name ?? '${Emojis.smilingFace} New Folder';
    file.parents = <String>[parentID];
    file.mimeType = mimeType;
    file.description = jsonEncode(metadata ?? <String, dynamic>{});
    return file;
  }
}
