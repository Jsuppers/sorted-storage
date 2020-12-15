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
        var commentsResponse =
            await storage.uploadCommentsFile(folderID: folderID);
        commentsID = commentsResponse.commentsID;
        print('found commentsID: $commentsID');
      }
      folderPermissionID = await _getPermissions(folderID, "anyone", "reader");
      commentsPermissionID =
          await _getPermissions(commentsID, "anyone", "writer");
    } catch (e) {
      print(e);
      print('commentsID: $commentsID, folderID: $folderID');
      return SharingState(false, message: "cannot retrieve permissions");
    }
    if (folderPermissionID != null && commentsPermissionID != null) {
      return SharingState(true);
    }
    return SharingState(false);
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
      if (folderPermissionID == null) {
        folderPermissionID = await _shareFile(folderID, "anyone", "reader");
        if (folderPermissionID == null) {
          folderPermissionID =
              await _getPermissions(folderID, "anyone", "reader");
        }
      }
      if (commentsPermissionID == null) {
        commentsPermissionID =
            await _getPermissions(commentsID, "anyone", "writer");
        if (commentsPermissionID == null) {
          commentsPermissionID =
              await _shareFile(commentsID, "anyone", "writer");
        }
      }
    } catch (e) {
      print(e);
      print('commentsID: $commentsID, folderID: $folderID');
      return SharingState(false,
          message: "error while sharing folder, please try again");
    }
    return SharingState(true);
  }

  Future<String> _shareFile(String fileID, String type, String role) async {
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
      print(e);
      return SharingState(true,
          message: "error while stopping sharing, please try again");
    }
    return SharingState(false);
  }
}
