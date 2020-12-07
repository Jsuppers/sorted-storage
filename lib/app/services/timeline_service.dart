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

  static List<String> getMediaThatAreUploading(EventContent content) {
    List<String> mediaBeingUploaded = List();
    for (MapEntry<String, StoryMedia> mediaEntry in content.images.entries) {
      if (mediaEntry.value.needsToUpload) {
        mediaBeingUploaded.add(mediaEntry.key);
      }
    }
    return mediaBeingUploaded;
  }

  static Future<Uint8List> getBytes(Stream<List<int>> stream) async {
    List<int> bytesList = List();
    await for (List<int> bytes in stream) {
      bytesList.addAll(bytes);
    }
    return Uint8List.fromList(bytesList);
  }

}
