import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mockito/mockito.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class MockGoogleDrive extends Mock implements GoogleDrive {}

main() {
  WidgetsFlutterBinding.ensureInitialized();

  test(
    'Given a empty images map When a getThumbnail request is made than we should return before requesting the file',
    () async {
      MockGoogleDrive mockGoogleDrive = MockGoogleDrive();

      String folderID = "mockFolder";
      String imageKey = "mockKey";
      Map<String, StoryMedia> images = Map();
      Map<String, List<String>> uploadingImages = Map();
      Function successCallback = () {};

      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
          images, uploadingImages, successCallback);

      verifyNever(mockGoogleDrive.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink'));
    },
  );

  test(
    'Given tries is 0 When a getThumbnail request is made than return',
        () async {
      MockGoogleDrive mockGoogleDrive = MockGoogleDrive();

      String folderID = "mockFolder";
      String imageKey = "mockKey";
      Map<String, StoryMedia> images = Map();
      Map<String, List<String>> uploadingImages = Map();
      Function successCallback = () {};

      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
          images, uploadingImages, successCallback, maxTries: 0);

      verifyNever(mockGoogleDrive.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink'));
    },
  );

  test(
    'Given a second retry When the second request has a thumbnail link than return',
        () async {
      MockGoogleDrive mockGoogleDrive = MockGoogleDrive();

      String expectedLink = "mockLink";
      String folderID = "mockFolder";
      String imageKey = "mockKey";
      Map<String, StoryMedia> images = Map();
      StoryMedia storyMedia = StoryMedia();
      images.putIfAbsent(imageKey, () => storyMedia);
      Map<String, List<String>> uploadingImages = Map();
      bool successCalled = false;
      Function successCallback = () {
        successCalled = true;
      };

      File firstResponse = File();
      firstResponse.hasThumbnail = false;
      File secondResponse = File();
      secondResponse.hasThumbnail = true;
      secondResponse.thumbnailLink = expectedLink;
      var answers = [firstResponse, secondResponse];
      when(mockGoogleDrive.getFile(imageKey, filter: 'id,hasThumbnail,thumbnailLink')).thenAnswer((_) => Future.value(answers.removeAt(0)));

      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
          images, uploadingImages, successCallback);

      verify(mockGoogleDrive.getFile(imageKey,
          filter: 'id,hasThumbnail,thumbnailLink')).called(2);
      expect(storyMedia.imageURL, expectedLink);
      assert(successCalled);
    },
  );

  test(
    'Given a checkNeedsRefreshing request When value stays null than successCallback does not get called',
        () async {


      String folderID = "mockFolderID";
      String imageKey = "mockImageKey";
      Map<String, List<String>> uploadingImages = Map();
      StoryContent localCopy = StoryContent();
      Map<String, StoryMedia> images = Map();
      StoryMedia storyMedia = StoryMedia();
      images.putIfAbsent(imageKey, () => storyMedia);
      localCopy.images = images;
      bool successCalled = false;
      Function successCallback = () {
        successCalled = true;
      };

      await RetryService.checkNeedsRefreshing(folderID, uploadingImages, localCopy,
          successCallback, seconds: 0, maxTries: 2);

      assert(successCalled == false);
    },
  );

  test(
    'Given a checkNeedsRefreshing request When image has url than successCallback gets called',
        () async {

      String folderID = "mockFolderID";
      String imageKey = "mockImageKey";
      Map<String, List<String>> uploadingImages = Map();
      StoryContent localCopy = StoryContent();
      Map<String, StoryMedia> images = Map();
      StoryMedia storyMedia = StoryMedia();
      storyMedia.imageURL = "validImageURL";
      images.putIfAbsent(imageKey, () => storyMedia);
      localCopy.images = images;
      bool successCalled = false;
      Function successCallback = () {
        successCalled = true;
      };

      await RetryService.checkNeedsRefreshing(folderID, uploadingImages, localCopy,
          successCallback, seconds: 0);

      assert(successCalled);
    },
  );
}
