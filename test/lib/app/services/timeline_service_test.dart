import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();

  test(
    'Given a folder ID of a valid main event When we call getEventWithFolderID Then return the main event',
    () async {
      String eventID = "event";
      String folderID = "folder";
      Map<String, TimelineData> timelineEvent = Map();

      TimelineData timelineData = TimelineData();
      StoryContent expected = StoryContent();
      expected.folderID = folderID;
      timelineData.mainStory = expected;

      timelineEvent.putIfAbsent(eventID, () => timelineData);

      StoryContent got = TimelineService.getEventWithFolderID(
          eventID, folderID, timelineEvent);

      expect(expected, got);
    },
  );

  test(
    'Given a folder ID of a valid sub event When we call getEventWithFolderID Then return the sub event',
    () async {
      String eventID = "event";
      String folderID = "folder";
      Map<String, TimelineData> timelineEvent = Map();

      TimelineData timelineData = TimelineData();
      StoryContent expected = StoryContent();
      expected.folderID = folderID;
      timelineData.mainStory = StoryContent();
      timelineData.subEvents = [];
      timelineData.subEvents.add(expected);

      timelineEvent.putIfAbsent(eventID, () => timelineData);

      StoryContent got = TimelineService.getEventWithFolderID(
          eventID, folderID, timelineEvent);

      expect(expected, got);
    },
  );


  test(
    'Given a invalid folder ID When we call getEventWithFolderID Then return null',
        () async {
      String eventID = "event";
      String folderID = "folder";
      Map<String, TimelineData> timelineEvent = Map();

      TimelineData timelineData = TimelineData();
      timelineData.mainStory = StoryContent();
      timelineData.subEvents = [];
      timelineData.subEvents.add(StoryContent());

      timelineEvent.putIfAbsent(eventID, () => timelineData);

      StoryContent got = TimelineService.getEventWithFolderID(
          eventID, folderID, timelineEvent);

      expect(got, null);
    },
  );
}
