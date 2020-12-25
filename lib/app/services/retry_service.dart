import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/google_drive.dart';

class RetryService {
  static Future getThumbnail(
      GoogleDrive storage,
      String folderID,
      String imageKey,
      Map<String, StoryMedia> images,
      Map<String, List<String>> uploadingImages,
      Function successCallback,
      {int maxTries = 10}) async {
    int exp = 10;
    if (maxTries > exp) {
      maxTries = 10;
    }
    if (maxTries == 0) {
      return null;
    }
    return Future.delayed(Duration(seconds: (exp - maxTries) * 2), () async {
      if (images == null || !images.containsKey(imageKey)) {
        print('images $images');
        return null;
      }

      File mediaFile = await storage.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink') as File;

      if (mediaFile.hasThumbnail) {
        print('thumbnail for image: $imageKey has been created!');
        images[imageKey].thumbnailURL = mediaFile.thumbnailLink;
        successCallback();
        return null;
      }

      print('waiting for a thumbnail for image: $imageKey');
      return getThumbnail(
          storage, folderID, imageKey, images, uploadingImages, successCallback,
          maxTries: maxTries - 1);
    });
  }

  static Future checkNeedsRefreshing(
      String folderID,
      Map<String, List<String>> uploadingImages,
      StoryContent localCopy,
      Function successCallback,
      {int maxTries = 60,
      int seconds = 10}) async {
    if (maxTries == 0) {
      return null;
    }
    return Future.delayed(Duration(seconds: seconds), () async {
      for (MapEntry entry in localCopy.images.entries) {
        if (entry.value.thumbnailURL == null) {
          print("still waiting for a thumbnail: ${entry.key}");
          return checkNeedsRefreshing(
              folderID, uploadingImages, localCopy, successCallback,
              maxTries: maxTries - 1, seconds: seconds);
        }
      }
      successCallback();
    });
  }
}
