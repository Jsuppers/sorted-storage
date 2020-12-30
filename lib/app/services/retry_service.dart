import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/google_drive.dart';

/// service for retrying
class RetryService {
  /// get thumbnail image for a file
  static Future<dynamic> getThumbnail(
      GoogleDrive storage,
      String folderID,
      String imageKey,
      Map<String, StoryMedia> images,
      Map<String, List<String>> uploadingImages,
      Function successCallback,
      {int maxTries = 10}) async {
    const int exp = 10;
    int currentTry = maxTries;
    if (maxTries > exp) {
      currentTry = 10;
    }
    if (maxTries == 0) {
      return null;
    }
    return Future<dynamic>.delayed(Duration(seconds: (exp - currentTry) * 2),
        () async {
      if (images == null || !images.containsKey(imageKey)) {
        return null;
      }

      final File mediaFile = await storage.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink') as File;

      if (mediaFile.hasThumbnail) {
        images[imageKey].thumbnailURL = mediaFile.thumbnailLink;
        successCallback();
        return null;
      }

      return getThumbnail(
          storage, folderID, imageKey, images, uploadingImages, successCallback,
          maxTries: currentTry - 1);
    });
  }

  /// a recursive wait method to keep checking if a thumbnail URL is available
  static Future<dynamic> checkNeedsRefreshing(
      String folderID,
      Map<String, List<String>> uploadingImages,
      StoryContent localCopy,
      Function successCallback,
      {int maxTries = 60,
      int seconds = 10}) async {
    if (maxTries == 0) {
      return null;
    }
    return Future<dynamic>.delayed(Duration(seconds: seconds), () async {
      for (final MapEntry<String, StoryMedia> entry
          in localCopy.images.entries) {
        if (entry.value.thumbnailURL == null) {
          return checkNeedsRefreshing(
              folderID, uploadingImages, localCopy, successCallback,
              maxTries: maxTries - 1, seconds: seconds);
        }
      }
      successCallback();
    });
  }
}
