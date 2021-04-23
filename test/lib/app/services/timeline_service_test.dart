//import 'package:flutter/material.dart';
//import 'package:test/test.dart';
//import 'package:web/app/models/story_content.dart';
//import 'package:web/app/models/timeline_data.dart';
//import 'package:web/app/services/timeline_service.dart';
//
//void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//
//  test(
//    'Given a folder ID of a valid main event '
//        'When we call getEventWithFolderID Then return the main event',
//    () async {
//      const String eventID = 'event';
//      const String folderID = 'folder';
//      final Map<String, StoryTimelineData> timelineEvent =
//      <String, StoryTimelineData>{};
//
//      final StoryTimelineData timelineData = StoryTimelineData();
//      final StoryContent expected = StoryContent();
//      expected.folderID = folderID;
//      timelineData.mainStory = expected;
//
//      timelineEvent.putIfAbsent(eventID, () => timelineData);
//
//      final StoryContent got = TimelineService.getStoryWithFolderID(
//          eventID, folderID, timelineEvent);
//
//      expect(expected, got);
//    },
//  );
//
//  test(
//    'Given a folder ID of a valid sub event '
//        'When we call getEventWithFolderID Then return the sub event',
//    () async {
//      const String eventID = 'event';
//      const String folderID = 'folder';
//      final Map<String, StoryTimelineData> timelineEvent =
//        <String, StoryTimelineData>{};
//
//      final StoryTimelineData timelineData = StoryTimelineData();
//      final StoryContent expected = StoryContent();
//      expected.folderID = folderID;
//      timelineData.mainStory = StoryContent();
//      timelineData.subEvents = <StoryContent>[];
//      timelineData.subEvents.add(expected);
//
//      timelineEvent.putIfAbsent(eventID, () => timelineData);
//
//      final StoryContent got = TimelineService.getStoryWithFolderID(
//          eventID, folderID, timelineEvent);
//
//      expect(expected, got);
//    },
//  );
//
//  test(
//    'Given a invalid folder ID When we call getEventWithFolderID '
//        'Then return null',
//    () async {
//      const String eventID = 'event';
//      const String folderID = 'folder';
//      final Map<String, StoryTimelineData> timelineEvent =
//        <String, StoryTimelineData>{};
//
//      final StoryTimelineData timelineData = StoryTimelineData();
//      timelineData.mainStory = StoryContent();
//      timelineData.subEvents = <StoryContent>[];
//      timelineData.subEvents.add(StoryContent());
//
//      timelineEvent.putIfAbsent(eventID, () => timelineData);
//
//      final StoryContent got = TimelineService.getStoryWithFolderID(
//          eventID, folderID, timelineEvent);
//
//      expect(got, null);
//    },
//  );
//}
