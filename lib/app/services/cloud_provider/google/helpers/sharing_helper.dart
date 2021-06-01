// Package imports:
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/models/sharing_information.dart';

class SharingHelper {
  // ignore: public_member_api_docs
  SharingHelper(this.driveApi);

  DriveApi? driveApi;

  static const String _sharedType = 'anyone';
  static const String _sharedRole = 'reader';

  Future<SharingInformation> isShared(String folderID) async {
    bool? shared;
    String? error;
    try {
      final List<String> sharedPermissions = await _getPermissions(folderID);
      shared = sharedPermissions.isNotEmpty;
    } catch (e) {
      error = 'cannot retrieve permissions';
    }
    return SharingInformation(shared: shared, error: error);
  }

  Future<SharingInformation> shareFolder(String folderID) async {
    bool? shared;
    String? error;
    try {
      final List<String> sharedPermissions = await _getPermissions(folderID);
      if (sharedPermissions.isEmpty) {
        await _createPermission(folderID, _sharedType, _sharedRole);
      }
      shared = true;
    } catch (e) {
      error = 'error while sharing folder, please try again';
    }
    return SharingInformation(shared: shared, error: error);
  }

  Future<SharingInformation> stopSharingFolder(String folderID) async {
    bool? shared;
    String? error;
    try {
      final List<String> sharedPermissions = await _getPermissions(folderID);
      if (sharedPermissions.isNotEmpty) {
        await deletePermission(folderID, sharedPermissions);
      }
      shared = false;
    } catch (e) {
      error = 'error while stopping sharing, please try again';
    }
    return SharingInformation(shared: shared, error: error);
  }

  Future<PermissionList> listPermissions(String fileID) async {
    return driveApi!.permissions.list(fileID);
  }

  Future<void> deletePermission(String fileID, List<String> permissions) async {
    for (final String permissionID in permissions) {
      driveApi!.permissions.delete(fileID, permissionID);
    }
  }

  Future<List<String>> _getPermissions(String folderID) async {
    final PermissionList list = await listPermissions(folderID);

    final List<String> sharedPermissions = <String>[];
    for (final Permission permission in list.permissions!) {
      if (permission.type == _sharedType && permission.role == _sharedRole) {
        sharedPermissions.add(permission.id!);
      }
    }
    return sharedPermissions;
  }

  Future<String?> _createPermission(
      String fileID, String type, String role) async {
    final Permission anyone = Permission();
    anyone.type = _sharedType;
    anyone.role = _sharedRole;

    final Permission permission =
        await driveApi!.permissions.create(anyone, fileID);
    return permission.id;
  }
}
