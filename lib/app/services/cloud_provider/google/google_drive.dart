// Dart imports:
import 'dart:async';

// Package imports:
import 'package:google_sign_in/google_sign_in.dart';
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
import 'package:web/app/services/cloud_provider/storage_service.dart';

/// service which communicates with google drive
class GoogleDrive implements StorageService {
  /// drive api
  DriveApi? _driveApi;

  late FolderHelper _folderHelper;
  late SharingHelper _sharingHelper;
  late ProfileHelper _profileHelper;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      DriveApi.driveFileScope,
    ],
  );

  @override
  Stream<usr.User?> userChange() {
    /// initialize the app with a non authenticated user
    _newUser();

    return _googleSignIn.onCurrentUserChanged.map((GoogleSignInAccount? user) {
      if (user == null) {
        return null;
      }
      final usr.User newUser = usr.User(
          displayName: user.displayName ?? '',
          email: user.email,
          photoUrl: user.photoUrl ?? '',
          headers: user.authHeaders);
      _newUser(user: newUser);
      return newUser;
    });
  }

  Future<void> _newUser({usr.User? user}) async {
    http.Client client;
    if (user != null) {
      client = ClientWithAuthHeaders(await user.headers);
    } else {
      client = ClientWithGoogleDriveKey();
    }
    _driveApi = DriveApi(client);
    _folderHelper = FolderHelper(_driveApi);
    _sharingHelper = SharingHelper(_driveApi);
    _profileHelper = ProfileHelper(_driveApi);
  }

  @override
  Future<bool> isSignedIn() {
    return _googleSignIn.isSignedIn();
  }

  @override
  Future<void> signIn() {
    return _googleSignIn.signIn();
  }

  @override
  Future<void> signInSilently() {
    return _googleSignIn.signInSilently();
  }

  @override
  Future<void> signOut() {
    return _googleSignIn.signOut();
  }

  @override
  Future<StorageInformation> getStorageInformation() async {
    return _profileHelper.getStorageInformation();
  }

  @override
  Future<Folder> getRootFolder() async {
    return _folderHelper.getRootFolder();
  }

  @override
  Future<Folder?> getFolder(String folderID, {String? folderName}) async {
    return _folderHelper.getFolder(folderID, folderName: folderName);
  }

  Future<Folder> updateFolder(String folderID,
      {String? folderName, required Folder folder}) async {
    return _folderHelper.updateFolder(folderID,
        folder: folder, folderName: folderName);
  }

  @override
  Future<Folder?> createFolder({Folder? parent}) async {
    return _folderHelper.createFolder(parent);
  }

  @override
  Future<void> updateMetadata(
      {required String fileId, required Map<String, dynamic> metadata}) async {
    await _folderHelper.updateMetadata(fileId, metadata);
  }

  @override
  Future<String?> updateFileName(String fileID, String name) async {
    return _folderHelper.updateFileName(fileID, name);
  }

  @override
  Future<String?> uploadFile(
      String folderID, FileData file, Stream<List<int>> data) async {
    return _folderHelper.uploadFileToFolder(folderID, file, data);
  }

  @override
  Future<dynamic> deleteResource(String fileID) async {
    return _folderHelper.delete(fileID);
  }

  @override
  Future<String?> getThumbnailURL(String fileID) async {
    final File file =
        await _folderHelper.getFile(fileID, filter: 'thumbnailLink') as File;
    return file.thumbnailLink;
  }

  @override
  Future<SharingInformation> isShared(String folderID) {
    return _sharingHelper.isShared(folderID);
  }

  @override
  Future<SharingInformation> shareFolder(String folderID) {
    return _sharingHelper.shareFolder(folderID);
  }

  @override
  Future<SharingInformation> stopSharingFolder(String folderID) {
    return _sharingHelper.stopSharingFolder(folderID);
  }
}
