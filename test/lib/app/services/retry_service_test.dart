//import 'package:flutter/material.dart';
//import 'package:flutter_test/flutter_test.dart';
//import 'package:googleapis/drive/v3.dart';
//import 'package:mockito/mockito.dart';
//import 'package:web/app/models/story_content.dart';
//import 'package:web/app/models/story_media.dart';
//import 'package:web/app/services/google_drive.dart';
//import 'package:web/app/services/retry_service.dart';
//
//class MockGoogleDrive extends Mock implements GoogleDrive {}
//
//main() {
//  WidgetsFlutterBinding.ensureInitialized();
//
//  test(
//    'Given a empty images map When a getThumbnail request '
//    'is made than we should return before requesting the file',
//    () async {
//      final MockGoogleDrive mockGoogleDrive = MockGoogleDrive();
//
//      const String folderID = 'mockFolder';
//      const String imageKey = 'mockKey';
//      final Map<String, StoryMedia> images = <String, StoryMedia>{};
//      final Map<String, List<String>> uploadingImages =
//          <String, List<String>>{};
//      Function successCallback = () {};
//
//      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
//          images, uploadingImages, successCallback);
//
//      verifyNever(mockGoogleDrive.getFile(imageKey,
//          filter: 'id,hasThumbnail,thumbnailLink'));
//    },
//  );
//
//  test(
//    'Given tries is 0 When a getThumbnail request is made than return',
//    () async {
//      final MockGoogleDrive mockGoogleDrive = MockGoogleDrive();
//
//      const String folderID = 'mockFolder';
//      const String imageKey = 'mockKey';
//      final Map<String, StoryMedia> images = <String, StoryMedia>{};
//      final Map<String, List<String>> uploadingImages =
//          <String, List<String>>{};
//      Function successCallback = () {};
//
//      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
//          images, uploadingImages, successCallback,
//          maxTries: 0);
//
//      verifyNever(mockGoogleDrive.getFile(imageKey,
//          filter: 'id,hasThumbnail,thumbnailLink'));
//    },
//  );
//
//  test(
//    'Given a second retry When the second '
//    'request has a thumbnail link than return',
//    () async {
//      final MockGoogleDrive mockGoogleDrive = MockGoogleDrive();
//
//      const String expectedLink = 'mockLink';
//      const String folderID = 'mockFolder';
//      const String imageKey = 'mockKey';
//      final Map<String, StoryMedia> images = <String, StoryMedia>{};
//      final StoryMedia storyMedia = StoryMedia();
//      images.putIfAbsent(imageKey, () => storyMedia);
//      final Map<String, List<String>> uploadingImages =
//          <String, List<String>>{};
//      bool successCalled = false;
//      Function successCallback = () {
//        successCalled = true;
//      };
//
//      final File firstResponse = File();
//      firstResponse.hasThumbnail = false;
//      final File secondResponse = File();
//      secondResponse.hasThumbnail = true;
//      secondResponse.thumbnailLink = expectedLink;
//      final List<File> answers = <File>[firstResponse, secondResponse];
//      when(mockGoogleDrive.getFile(imageKey,
//              filter: 'id,hasThumbnail,thumbnailLink'))
//          .thenAnswer((_) => Future<File>.value(answers.removeAt(0)));
//
//      await RetryService.getThumbnail(mockGoogleDrive, folderID, imageKey,
//          images, uploadingImages, successCallback);
//
//      verify(mockGoogleDrive.getFile(imageKey,
//              filter: 'id,hasThumbnail,thumbnailLink'))
//          .called(2);
//      expect(storyMedia.thumbnailURL, expectedLink);
//      assert(successCalled);
//    },
//  );
//
//  test(
//    'Given a checkNeedsRefreshing request'
//    ' When value stays null than successCallback does not get called',
//    () async {
//      const String folderID = 'mockFolderID';
//      const String imageKey = 'mockImageKey';
//      final Map<String, List<String>> uploadingImages =
//          <String, List<String>>{};
//      final StoryContent localCopy = StoryContent();
//      final Map<String, StoryMedia> images = <String, StoryMedia>{};
//      final StoryMedia storyMedia = StoryMedia();
//      images.putIfAbsent(imageKey, () => storyMedia);
//      localCopy.images = images;
//      bool successCalled = false;
//      Function successCallback = () {
//        successCalled = true;
//      };
//
//      await RetryService.checkNeedsRefreshing(
//          folderID, uploadingImages, localCopy, successCallback,
//          seconds: 0, maxTries: 2);
//
//      assert(successCalled == false);
//    },
//  );
//
//  test(
//    'Given a checkNeedsRefreshing request '
//    'When image has url than successCallback gets called',
//    () async {
//      const String folderID = 'mockFolderID';
//      const String imageKey = 'mockImageKey';
//      final Map<String, List<String>> uploadingImages =
//          <String, List<String>>{};
//      final StoryContent localCopy = StoryContent();
//      final Map<String, StoryMedia> images = <String, StoryMedia>{};
//      final StoryMedia storyMedia = StoryMedia();
//      storyMedia.thumbnailURL = 'validImageURL';
//      images.putIfAbsent(imageKey, () => storyMedia);
//      localCopy.images = images;
//      bool successCalled = false;
//      Function successCallback = () {
//        successCalled = true;
//      };
//
//      await RetryService.checkNeedsRefreshing(
//          folderID, uploadingImages, localCopy, successCallback,
//          seconds: 0);
//
//      assert(successCalled);
//    },
//  );
//}
