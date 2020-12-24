import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/app/services/google_drive.dart';

/// SharingBloc handles creating and delete permissions for a folder to allow
/// This folder to be shared or un-shared
class SharingBloc extends Bloc<ShareEvent, SharingState> {
  /// constructor
  SharingBloc(String folderID, String CommentsID, GoogleDrive storage) : super(null) {
    _folderID = folderID;
    _commentsID = CommentsID;
    _storage = storage;
    this.add(InitialEvent());
  }

  String _folderID;
  String _commentsID;
  GoogleDrive _storage;
  String _folderPermissionID;
  String _commentsPermissionID;

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
      if (_commentsID == null) {
        await _createCommentsFile();
      }
      _folderPermissionID = await _getPermissions(_folderID, "anyone", "reader");
      _commentsPermissionID = await _getPermissions(_commentsID, "anyone", "writer");
    } catch (e) {
      print('commentsID: $_commentsID, folderID: $_folderID, error: $e');
      return SharingNotSharedState(message: "cannot retrieve permissions");
    }
    if (_folderPermissionID != null && _commentsPermissionID != null) {
      return SharingSharedState();
    }
    return SharingNotSharedState();
  }

  Future _createCommentsFile() async {
    var commentsResponse = await _storage.uploadCommentsFile(folderID: _folderID);
    _commentsID = commentsResponse.commentsID;
  }

  Future<String> _getPermissions(
      String folderID, String type, String role) async {
    PermissionList list = await _storage.listPermissions(folderID);

    for (Permission permission in list.permissions) {
      if (permission.type == type && permission.role == role) {
        return permission.id;
      }
    }
    return null;
  }

  Future<SharingState> _shareFolder() async {
    try {
      _folderPermissionID = await _shareFile(_folderPermissionID, _folderID, "anyone", "reader");
      _commentsPermissionID = await _shareFile(_commentsPermissionID, _commentsID, "anyone", "writer");
    } catch (e) {
      print('commentsID: $_commentsID, folderID: $_folderID, error: $e');
      return SharingNotSharedState(
          message: "error while sharing folder, please try again");
    }
    if (_folderPermissionID != null && _commentsPermissionID != null) {
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

    Permission permission = await _storage.createPermission(fileID, anyone);
    return permission.id;
  }

  Future<SharingState> _stopSharingFolder() async {
    try {
      await _storage.deletePermission(_commentsID, _commentsPermissionID);
      _commentsPermissionID = null;
      await _storage.deletePermission(_folderID, _folderPermissionID);
      _folderPermissionID = null;
    } catch (e) {
      print('error: $e');
      return SharingSharedState(
          message: "error while stopping sharing, please try again");
    }
    return SharingNotSharedState();
  }
}
