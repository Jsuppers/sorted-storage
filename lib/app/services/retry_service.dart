// Project imports:
import 'package:web/app/services/cloud_provider/storage_service.dart';

// Project imports:

/// service for retrying
class RetryService {
  /// get thumbnail image for a file
  static Future<String?> getThumbnail(StorageService storage,
      String? thumbnailURL, String folderID, String imageKey,
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
      final String? thumbnailURL = await storage.getThumbnailURL(imageKey);
      return getThumbnail(storage, thumbnailURL, folderID, imageKey,
          retrieveThumbnail: retrieveThumbnail, maxTries: currentTry - 1);
    });
  }
}
