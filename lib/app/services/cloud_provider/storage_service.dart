// Project imports:
import 'package:web/app/models/file.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/user.dart';

abstract class StorageService {
  StorageService();

  Stream<User?> userChange();
  Future<bool> isSignedIn();
  Future<User?> signIn();
  Future<User?> signInSilently();
  Future<void> signOut();
  Future<Folder?> getRootFolder();
  Future<Folder?> getFolder({String folderID});
  Future<Folder?> createFolder({Folder? parent});
  Future<void> updateMetadata({String fileId, Map<String, dynamic> metadata});
  Future<void> updateFileName(String fileID, String name);
  Future<void> uploadFile(Map<String, File> images, Folder folder);
  Future<dynamic> getFile(String fileID, {String? filter});
  Future<dynamic> deleteFile(String fileID);
  Future<bool> isShared(String folderID);
  Future<void> shareFolder(String folderID);
  Future<void> stopSharingFolder(String folderID);
}
