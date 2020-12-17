import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/app/services/google_drive.dart';

class SharingBloc extends Bloc<ShareEvent, SharingState> {
  String folderID;
  String commentsID;
  GoogleDrive storage;
  String folderPermissionID;
  String commentsPermissionID;

  SharingBloc(this.folderID, this.commentsID, this.storage) : super(null) {
    this.add(InitialEvent());
  }

  @override
  Stream<SharingState> mapEventToState(ShareEvent event) async* {
    if (event is InitialEvent) {
      yield await _getPermissionsAll();
    } else if (event is StartSharingEvent) {
      yield await _shareFolder();
    } else if (event is StopSharingEvent) {
      yield await _stopSharingFolder();
    }
  }

  Future<SharingState> _getPermissionsAll() async {
    try {
      if (commentsID == null) {
        await _createCommentsFile();
      }
      folderPermissionID = await _getPermissions(folderID, "anyone", "reader");
      commentsPermissionID = await _getPermissions(commentsID, "anyone", "writer");
    } catch (e) {
      print('commentsID: $commentsID, folderID: $folderID, error: $e');
      return SharingNotSharedState(message: "cannot retrieve permissions");
    }
    if (folderPermissionID != null && commentsPermissionID != null) {
      return SharingSharedState();
    }
    return SharingNotSharedState();
  }

  Future _createCommentsFile() async {
    var commentsResponse = await storage.uploadCommentsFile(folderID: folderID);
    commentsID = commentsResponse.commentsID;
  }

  Future<String> _getPermissions(
      String folderID, String type, String role) async {
    PermissionList list = await storage.listPermissions(folderID);

    for (Permission permission in list.permissions) {
      if (permission.type == type && permission.role == role) {
        return permission.id;
      }
    }
    return null;
  }

  Future<SharingState> _shareFolder() async {
    try {
      folderPermissionID = await _shareFile(folderPermissionID, folderID, "anyone", "reader");
      commentsPermissionID = await _shareFile(commentsPermissionID, commentsID, "anyone", "writer");
    } catch (e) {
      print('commentsID: $commentsID, folderID: $folderID, error: $e');
      return SharingNotSharedState(
          message: "error while sharing folder, please try again");
    }
    if (folderPermissionID != null && commentsPermissionID != null) {
      return SharingSharedState();
    }
    return SharingNotSharedState();
  }

  Future<String> _shareFile(String permissionID, String fileID, String type, String role) async {
    if (permissionID == null) {
      permissionID = await _getPermissions(fileID, type, role);
      if (permissionID == null) {
        permissionID = await _createPermission(fileID, type, role);
      }
    }
    return permissionID;
  }

  Future<String> _createPermission(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await storage.createPermission(fileID, anyone);
    return permission.id;
  }

  Future<SharingState> _stopSharingFolder() async {
    try {
      await storage.deletePermission(commentsID, commentsPermissionID);
      commentsPermissionID = null;
      await storage.deletePermission(folderID, folderPermissionID);
      folderPermissionID = null;
    } catch (e) {
      print('error: $e');
      return SharingSharedState(
          message: "error while stopping sharing, please try again");
    }
    return SharingNotSharedState();
  }
}
