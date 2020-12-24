import 'package:web/ui/widgets/timeline_card.dart';

class TimelineService {
  static StoryContent getEventWithFolderID(String eventID, String folderID,
      Map<String, TimelineData> timelineEvent) {
    TimelineData event = timelineEvent[eventID];
    if (event.mainStory.folderID == folderID) {
      return event.mainStory;
    } else {
      for (int i = 0; i < event.subEvents.length; i++) {
        StoryContent element = event.subEvents[i];
        if (element.folderID == folderID) {
          return element;
        }
      }
    }
    return null;
  }

  /// Creates a unique temp name based on the parents ID and current time
  static String createUniqueTempName(String parentID) {
    final int milliseconds = DateTime.now().millisecondsSinceEpoch;
    return 'temp_${parentID}_${milliseconds.toString()}';
  }
}
