import 'dart:typed_data';

import 'package:web/ui/widgets/timeline_card.dart';

class TimelineService {
  static EventContent getEventWithFolderID(String eventID, String folderID,
      Map<String, TimelineData> timelineEvent) {
    TimelineData event = timelineEvent[eventID];
    if (event.mainEvent.folderID == folderID) {
      return event.mainEvent;
    } else {
      for (int i = 0; i < event.subEvents.length; i++) {
        EventContent element = event.subEvents[i];
        if (element.folderID == folderID) {
          return element;
        }
      }
    }
    return null;
  }
}
