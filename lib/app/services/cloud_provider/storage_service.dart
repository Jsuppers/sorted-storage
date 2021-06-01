// Project imports:
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/sharing_information.dart';
import 'package:web/app/models/storage_information.dart';
import 'package:web/app/models/user.dart';

abstract class StorageService {
  Stream<User?> userChange();
  Future<bool> isSignedIn();
  Future<void> signIn();
  Future<void> signInSilently();
  Future<void> signOut();
  Future<StorageInformation> getStorageInformation();
  Future<Folder?> getRootFolder();
  Future<Folder?> getFolder(String folderID, {String? folderName});
  Future<Folder> updateFolder(String folderID,
      {String? folderName, required Folder folder});
  Future<Folder?> createFolder({Folder? parent});
  Future<void> updateMetadata(
      {required String fileId, required Map<String, dynamic> metadata});
  Future<void> updateFileName(String fileID, String name);
  Future<String?> uploadFile(
      String folderID, FileData file, Stream<List<int>> dataStream);
  Future<dynamic> deleteResource(String resourceID);
  Future<String?> getThumbnailURL(String fileID);
  Future<SharingInformation> isShared(String folderID);
  Future<SharingInformation> shareFolder(String folderID);
  Future<SharingInformation> stopSharingFolder(String folderID);
}
