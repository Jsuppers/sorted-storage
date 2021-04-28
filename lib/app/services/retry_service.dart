// Package imports:
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/services/google_drive.dart';

/// service for retrying
class RetryService {
  /// get thumbnail image for a file
  static Future<String?> getThumbnail(GoogleDrive storage, String? thumbnailURL,
      String folderID, String imageKey,
      {int maxTries = 10, bool retrieveThumbnail = false}) async {
    if (thumbnailURL != null) {
      return thumbnailURL;
    }
    if (retrieveThumbnail != true) {
      return null;
    }
    const int exp = 10;
    int currentTry = maxTries;
    if (maxTries > exp) {
      currentTry = 10;
    }
    if (maxTries == 0) {
      return null;
    }
    return Future<String?>.delayed(Duration(seconds: (exp - currentTry) * 2),
        () async {
      final File mediaFile =
          await storage.getFile(imageKey, filter: 'thumbnailLink') as File;

      return getThumbnail(storage, mediaFile.thumbnailLink, folderID, imageKey,
          retrieveThumbnail: retrieveThumbnail, maxTries: currentTry - 1);
    });
  }
}
