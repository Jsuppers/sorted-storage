// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/models/storage_information.dart';

class ProfileHelper {
  ProfileHelper(this.driveApi);

  DriveApi? driveApi;

  /// retrieve storage information
  Future<StorageInformation> getStorageInformation() async {
    final About? about = await driveApi?.about.get($fields: 'storageQuota');
    if (about == null) {
      return StorageInformation();
    }

    final AboutStorageQuota? quota = about.storageQuota;
    return StorageInformation(
        limit: _formatBytes(quota?.limit, 0),
        usage: _formatBytes(quota?.usage, 0),
        percent: _calculatePercentage(quota?.usage, quota?.limit));
  }

  static double _calculatePercentage(String? usageString, String? limitString) {
    if (usageString == null || limitString == null) {
      return 0;
    }
    final double usage = double.parse(usageString);
    final double limit = double.parse(limitString);
    return usage / limit;
  }

  static String _formatBytes(String? stringBytes, int decimals) {
    try {
      if (stringBytes == null) {
        return '';
      }
      final int bytes = int.parse(stringBytes);
      if (bytes <= 0) {
        return '0 B';
      }
      const List<String> suffixes = <String>[
        'B',
        'KB',
        'MB',
        'GB',
        'TB',
        'PB',
        'EB',
        'ZB',
        'YB'
      ];
      final int i = (log(bytes) / log(1024)).floor();
      final String val = (bytes / pow(1024, i)).toStringAsFixed(decimals);
      return '$val ${suffixes[i]}';
    } catch (e) {
      return '';
    }
  }
}
