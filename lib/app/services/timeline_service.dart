import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';

/// service for various functions regarding the timeline
class TimelineService {
  /// Retrieves a story with the given folder ID
  static StoryContent getStoryWithFolderID(String parentID, String folderID,
      Map<String, StoryTimelineData> timelineEvent) {
    final StoryTimelineData event = timelineEvent[parentID];
    if (event.mainStory.folderID == folderID) {
      return event.mainStory;
    } else {
      for (int i = 0; i < event.subEvents.length; i++) {
        final StoryContent element = event.subEvents[i];
        if (element.folderID == folderID) {
          return element;
        }
      }
    }
    return null;
  }
}
