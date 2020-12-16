import 'dart:async';
import 'dart:math';

import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/storage_information.dart';

class GoogleStorageService{
  static Future<StorageInformation> getStorageInformation(DriveApi driveApi) async {
    About about = await driveApi.about.get($fields: 'storageQuota');

    var information = StorageInformation(
        limit: formatBytes(about.storageQuota.limit, 0),
        usage: formatBytes(about.storageQuota.usage, 0),
        percent: calculatePercentage(about.storageQuota.usage, about.storageQuota.limit)
    );
    print('received information limit: ${information.limit} '
        'usage: ${information.usage}, percent: ${information.percent}');
    return information;
  }

  static double calculatePercentage(String usageString, String limitString) {
    var usage = double.parse(usageString);
    var limit = double.parse(limitString);
    return usage / limit;
  }

  static String formatBytes(String stringBytes, int decimals) {
    try {
      var bytes = int.parse(stringBytes);
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      var i = (log(bytes) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
          ' ' +
          suffixes[i];
    } catch (e) {
      return "";
    }
  }
}
