// Project imports:
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';

/// service for various functions regarding the timeline
class TimelineService {
  /// Retrieves a story with the given folder ID
  static StoryContent? getStoryWithFolderID(String parentID, String folderID,
      Map<String, StoryTimelineData> timelineEvent) {
    final StoryTimelineData? event = timelineEvent[parentID];
    if (event == null) {
      return null;
    }
    if (event.mainStory.folderID == folderID) {
      return event.mainStory;
    } else {
      for (int i = 0; i < event.subEvents!.length; i++) {
        final StoryContent element = event.subEvents![i];
        if (element.folderID == folderID) {
          return element;
        }
      }
    }
    return null;
  }

  /// Removes a image with the given key
  static void removeImage(String imageKey, StoryTimelineData folder) {
    if (folder.mainStory.images!.containsKey(imageKey)) {
      folder.mainStory.images!.removeWhere((String key, _) => key == imageKey);
      return;
    } else {
      for (int i = 0; i < folder.subEvents!.length; i++) {
        final StoryContent element = folder.subEvents![i];
        if (element.images!.containsKey(imageKey)) {
          element.images!.removeWhere((String key, _) => key == imageKey);
          return;
        }
      }
    }
  }

  /// Removes a image with the given key
  static void updateImage(
      String imageKey, int newIndex, StoryTimelineData folder) {
    if (folder.mainStory.images!.containsKey(imageKey)) {
      folder.mainStory.images!.update(imageKey, (value) {
        value.index = newIndex;
        return value;
      });
      return;
    } else {
      for (int i = 0; i < folder.subEvents!.length; i++) {
        final StoryContent element = folder.subEvents![i];
        if (element.images!.containsKey(imageKey)) {
          element.images!.update(imageKey, (value) {
            value.index = newIndex;
            return value;
          });
          return;
        }
      }
    }
  }
}
