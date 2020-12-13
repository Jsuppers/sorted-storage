import 'package:googleapis/drive/v3.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class RetryService {
  static void getThumbnail(
      GoogleDrive storage,
      String folderID,
      String imageKey,
      Map<String, StoryMedia> images,
      Map<String, List<String>> uploadingImages,
      Function successCallback,
      {int maxTries = 10}) {
    int exp = 10;
    if (maxTries > exp) {
      maxTries = 10;
    }
    if (maxTries == 0) {
      return;
    }
    Future.delayed(Duration(seconds: (exp - maxTries) * 2), () async {
      if (images == null || !images.containsKey(imageKey)) {
        print('images $images');
        return;
      }

      File mediaFile = await storage.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink');

      if (mediaFile.hasThumbnail) {
        print(
            "thumbnail for image: $imageKey has been created! ${mediaFile.thumbnailLink}");
        images[imageKey].imageURL = mediaFile.thumbnailLink;
        successCallback();
        return;
      }

      print("waiting for a thumbnail for image: $imageKey");
      getThumbnail(
          storage, folderID, imageKey, images, uploadingImages, successCallback,
          maxTries: maxTries - 1);
    });
  }

  static void checkNeedsRefreshing(
      String folderID,
      Map<String, List<String>> uploadingImages,
      EventContent localCopy,
      Function successCallback,
      {int maxTries = 60}) {
    if (maxTries == 0) {
      return;
    }
    Future.delayed(Duration(seconds: 10), () async {
      for (MapEntry entry in localCopy.images.entries) {
        if (entry.value.imageURL == null) {
          print("still waiting for a thumbnail: ${entry.key}");
          checkNeedsRefreshing(
              folderID, uploadingImages, localCopy, successCallback,
              maxTries: maxTries - 1);
          return;
        }
      }
      successCallback();
    });
  }
}
