// Package imports:
import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/app/services/google_drive.dart';

/// SharingBloc handles creating and delete permissions for a folder to allow
/// This folder to be shared or un-shared
class SharingBloc extends Bloc<ShareEvent, SharingState?> {
  /// constructor
  SharingBloc(String folderID, GoogleDrive storage) : super(null) {
    _folderID = folderID;
    _storage = storage;
    add(InitialEvent());
  }

  late String _folderID;
  late GoogleDrive _storage;
  String? _folderPermissionID;

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
      _folderPermissionID =
          await _getPermissions(_folderID, 'anyone', 'reader');
    } catch (e) {
      return SharingNotSharedState(errorMessage: 'cannot retrieve permissions');
    }
    if (_folderPermissionID != null) {
      return SharingSharedState();
    }
    return SharingNotSharedState();
  }

  Future<String?> _getPermissions(
      String folderID, String type, String role) async {
    final PermissionList list = await _storage.listPermissions(folderID);

    for (final Permission permission in list.permissions!) {
      if (permission.type == type && permission.role == role) {
        return permission.id;
      }
    }
    return null;
  }

  Future<SharingState> _shareFolder() async {
    try {
      _folderPermissionID =
          await _shareFile(_folderPermissionID!, _folderID, 'anyone', 'reader');
    } catch (e) {
      return SharingNotSharedState(
          errorMessage: 'error while sharing folder, please try again');
    }
    if (_folderPermissionID != null) {
      return SharingSharedState();
    }
    return SharingNotSharedState();
  }

  Future<String> _shareFile(
      String permissionID, String fileID, String type, String role) async {
    if (permissionID == null) {
      String? perm = await _getPermissions(fileID, type, role);
      return perm ??= await _createPermission(fileID, type, role) ?? '';
    }
    return permissionID;
  }

  Future<String?> _createPermission(
      String fileID, String type, String role) async {
    final Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    final Permission permission =
        await _storage.createPermission(fileID, anyone);
    return permission.id;
  }

  Future<SharingState> _stopSharingFolder() async {
    try {
      await _storage.deletePermission(_folderID, _folderPermissionID!);
      _folderPermissionID = null;
    } catch (e) {
      return SharingSharedState(
          errorMessage: 'error while stopping sharing, please try again');
    }
    return SharingNotSharedState();
  }
}
