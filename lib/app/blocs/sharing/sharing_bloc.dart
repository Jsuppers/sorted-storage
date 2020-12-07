
import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';

class SharingBloc extends Bloc<ShareEvent, bool> {
  String folderID;
  String commentsID;
  DriveApi driveApi;
  String folderPermissionID;
  String commentsPermissionID;

  SharingBloc(this.driveApi, this.folderID, this.commentsID) : super(null) {
    this.add(InitialEvent());
  }

  @override
  Stream<bool> mapEventToState(ShareEvent event) async* {
    if (event is InitialEvent){
      yield await _getPermissionsAll();
    }
    else if (event is StartSharingEvent){
      yield await _shareFolder();
    }
    else if (event is StopSharingEvent){
      yield await _stopSharingFolder();
    }
  }

  Future<bool> _getPermissionsAll() async {
    folderPermissionID = await _getPermissions(folderID, "anyone", "reader");
    commentsPermissionID = await _getPermissions(commentsID, "anyone", "writer");
    return folderPermissionID != null && commentsPermissionID != null;
  }

  Future<String> _getPermissions(String folderID, String type, String role) async {
    PermissionList list = await driveApi.permissions.list(folderID);

    for (Permission permission in list.permissions) {
      if (permission.type == type && permission.role == role) {
        return permission.id;
      }
    }
    return null;
  }

  Future<bool> _shareFolder() async {
    if (folderPermissionID == null) {
      folderPermissionID = await _shareFile(folderID, "anyone", "reader");
    }
    if (commentsPermissionID == null) {
      commentsPermissionID = await _shareFile(commentsID, "anyone", "writer");
    }
    return true;

  }

  Future<String> _shareFile(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await driveApi.permissions.create(anyone, fileID);
    return permission.id;
  }

  Future<bool> _stopSharingFolder() async {
    await driveApi.permissions.delete(commentsID, commentsPermissionID);
    commentsPermissionID = null;
    await driveApi.permissions.delete(folderID, folderPermissionID);
    folderPermissionID = null;
    return false;
  }
}