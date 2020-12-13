
import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';

class SharingBloc extends Bloc<ShareEvent, SharingState> {
  String folderID;
  String commentsID;
  DriveApi driveApi;
  String folderPermissionID;
  String commentsPermissionID;

  SharingBloc(this.driveApi, this.folderID, this.commentsID) : super(null) {
    this.add(InitialEvent());
  }

  @override
  Stream<SharingState> mapEventToState(ShareEvent event) async* {
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

  Future<SharingState> _getPermissionsAll() async {
    try {
      folderPermissionID = await _getPermissions(folderID, "anyone", "reader");
      commentsPermissionID =
      await _getPermissions(commentsID, "anyone", "writer");
    } catch (e) {
      return SharingState(false, message: "cannot retrieve permissions");
    }
    if (folderPermissionID != null && commentsPermissionID != null) {
      return SharingState(true);
    }
    return SharingState(false);
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

  Future<SharingState> _shareFolder() async {
    try {
      if (folderPermissionID == null) {
        folderPermissionID = await _shareFile(folderID, "anyone", "reader");
      }
      if (commentsPermissionID == null) {
        commentsPermissionID = await _shareFile(commentsID, "anyone", "writer");
      }
    } catch (e) {
      return SharingState(false, message: "error while sharing folder, please try again");
    }
    return SharingState(true);

  }

  Future<String> _shareFile(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await driveApi.permissions.create(anyone, fileID);
    return permission.id;
  }

  Future<SharingState> _stopSharingFolder() async {
    try {
      await driveApi.permissions.delete(commentsID, commentsPermissionID);
        commentsPermissionID = null;
      await driveApi.permissions.delete(folderID, folderPermissionID);
      folderPermissionID = null;
    } catch (e) {
      return SharingState(true,  message: "error while stopping sharing, please try again");
    }
    return SharingState(false);
  }
}
