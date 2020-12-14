import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class LocalChanges {
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;

  LocalChanges(this.cloudStories, this.localStories);

  Stream<TimelineState> changeLocalState(
      TimelineLocalEvent event, Function(TimelineEvent) callback) async* {
    switch (event.type) {
      case TimelineMessageType.cancel_story:
        localStories[event.folderId] =
            TimelineData.clone(cloudStories[event.folderId]);
        localStories[event.folderId].locked = true;
        yield TimelineState(TimelineMessageType.cancel_story, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_story:
        localStories[event.folderId].locked = false;
        yield TimelineState(TimelineMessageType.edit_story, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_description:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.description = event.data;
        break;
      case TimelineMessageType.edit_title:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.title = event.data;
        break;
      case TimelineMessageType.edit_timestamp:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.timestamp = event.data;
        break;
      case TimelineMessageType.add_image:
        var eventContent = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        try {
          FilePicker.platform
              .pickFiles(
                  type: FileType.media,
                  allowMultiple: true,
                  withReadStream: true)
              .then((file) {
            if (file == null || file.files == null || file.files.length == 0) {
              return file;
            }
            for (int i = 0; i < file.files.length; i++) {
              PlatformFile element = file.files[i];
              String mime = lookupMimeType(element.name);
              eventContent.images.putIfAbsent(
                  element.name,
                  () => StoryMedia(
                      stream: element.readStream,
                      size: element.size,
                      isVideo: mime.startsWith("video/"),
                      isDocument: !mime.startsWith("video/") &&
                          !mime.startsWith("image/")));
            }
            callback(TimelineEvent(TimelineMessageType.picked_image,
                folderId: event.folderId));
            return file;
          });
        } catch (e) {
          print(e);
        }

        break;
      case TimelineMessageType.create_sub_story:
        var story = localStories[event.parentId];
        String uniqueName = "temp_" +
            event.parentId +
            "_" +
            DateTime.now().millisecondsSinceEpoch.toString();
        story.subEvents.add(EventContent(
          folderID: uniqueName,
          timestamp: story.mainEvent.timestamp,
          images: Map(),
          comments: AdventureComments(comments: []),
          subEvents: [],
        ));
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.delete_sub_story:
        var story = localStories[event.parentId];
        story.subEvents
            .removeWhere((element) => element.folderID == event.folderId);
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.parentId);
        break;
      case TimelineMessageType.delete_image:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.images.remove(event.data);
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.edit_emoji:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.emoji = event.data;
        yield TimelineState(TimelineMessageType.edit_emoji, localStories,
            folderID: event.folderId, data: event.data);
        break;
      default:
        break;
    }
  }
}
