// Dart imports:
import 'dart:async';

// Package imports:
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/http_client.dart';
import 'package:web/app/models/sharing_information.dart';
import 'package:web/app/models/storage_information.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/cloud_provider/google/helpers/folder_helper.dart';
import 'package:web/app/services/cloud_provider/google/helpers/profile_helper.dart';
import 'package:web/app/services/cloud_provider/google/helpers/sharing_helper.dart';

/// service which communicates with google drive
class GoogleDrive {
  GoogleDrive();

  /// drive api
  DriveApi? driveApi;

  late FolderHelper _folderHelper;
  late SharingHelper _sharingHelper;
  late ProfileHelper _profileHelper;

  void newUser({usr.User? user}) {
    http.Client client;
    if (user != null) {
      client = ClientWithAuthHeaders(user.headers);
    } else {
      client = ClientWithGoogleDriveKey();
    }
    driveApi = DriveApi(client);
    _folderHelper = FolderHelper(driveApi);
    _sharingHelper = SharingHelper(driveApi);
    _profileHelper = ProfileHelper(driveApi);
  }

  Future<StorageInformation> getStorageInformation() async {
    return _profileHelper.getStorageInformation();
  }

  Future<File> updateMetadata(
      String fileId, Map<String, dynamic> metadata) async {
    return _folderHelper.updateMetadata(fileId, metadata);
  }

  /// upload a data stream to a file, and return the file's id
  Future<String?> uploadFileToFolder(String folderID, String imageName,
      FileData fileData, Stream<List<int>> dataStream) async {
    return _folderHelper.uploadFileToFolder(
        folderID, imageName, fileData, dataStream);
  }

  Future<Folder?> createFolder(Folder? parent) async {
    return _folderHelper.createFolder(parent);
  }

  Future<String?> updateFileName(String fileID, String name) async {
    return _folderHelper.updateFileName(fileID, name);
  }

  Future<dynamic> delete(String fileID) async {
    return _folderHelper.delete(fileID);
  }

  Future<dynamic> getFile(String fileID, {String? filter}) async {
    return _folderHelper.getFile(fileID, filter: filter);
  }

  Future<FileList> listFiles(String query, {String? filter}) async {
    return _folderHelper.listFiles(query, filter: filter);
  }

  Future<Folder> getRootFolder() async {
    return _folderHelper.getRootFolder();
  }

  Future<Folder> updateFolder(String folderID,
      {String? folderName, required Folder folder}) async {
    return _folderHelper.updateFolder(folderID,
        folder: folder, folderName: folderName);
  }

  Future<Folder> getFolder(String folderID, {String? folderName}) async {
    return _folderHelper.getFolder(folderID, folderName: folderName);
  }

  Future<SharingInformation> isShared(String folderID) {
    return _sharingHelper.isShared(folderID);
  }

  Future<SharingInformation> shareFolder(String folderID) {
    return _sharingHelper.shareFolder(folderID);
  }

  Future<SharingInformation> stopSharingFolder(String folderID) {
    return _sharingHelper.stopSharingFolder(folderID);
  }
}
