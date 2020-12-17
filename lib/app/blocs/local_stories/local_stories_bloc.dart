import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class LocalStoriesBloc extends Bloc<LocalStoriesEvent, LocalStoriesState> {
  Map<String, TimelineData> localStories;

  LocalStoriesBloc({this.localStories})
      : super(LocalStoriesState(LocalStoriesType.initial_state, localStories));

  @override
  Stream<LocalStoriesState> mapEventToState(event) async* {
    switch (event.type) {
      case LocalStoriesType.cancel_story:
        localStories[event.folderId] =
            TimelineData.clone(event.data[event.folderId] as TimelineData);
        localStories[event.folderId].locked = true;
        yield LocalStoriesState(LocalStoriesType.cancel_story, localStories,
            folderID: event.folderId);
        break;
      case LocalStoriesType.edit_story:
        localStories[event.folderId].locked = false;
        yield LocalStoriesState(LocalStoriesType.edit_story, localStories,
            folderID: event.folderId);
        break;
      case LocalStoriesType.edit_description:
        EventContent eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.description = event.data as String;
        break;
      case LocalStoriesType.edit_title:
        EventContent eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.title = event.data as String;
        break;
      case LocalStoriesType.edit_timestamp:
        EventContent eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.timestamp = event.data as int;
        break;
      case LocalStoriesType.add_image:
        EventContent eventContent = TimelineService.getEventWithFolderID(
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
            this.add(LocalStoriesEvent(LocalStoriesType.picked_image,
                folderId: event.folderId));
            return file;
          });
        } catch (e) {
          print(e);
        }

        break;
      case LocalStoriesType.create_sub_story:
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
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case LocalStoriesType.delete_sub_story:
        var story = localStories[event.parentId];
        story.subEvents
            .removeWhere((element) => element.folderID == event.folderId);
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, localStories,
            folderID: event.parentId);
        break;
      case LocalStoriesType.delete_image:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.images.remove(event.data);
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case LocalStoriesType.edit_emoji:
        var eventData = TimelineService.getEventWithFolderID(
            event.parentId, event.folderId, localStories);
        eventData.emoji = event.data as String;
        yield LocalStoriesState(LocalStoriesType.edit_emoji, localStories,
            folderID: event.folderId, data: event.data);
        break;
      case LocalStoriesType.picked_image:
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case LocalStoriesType.syncing_story_end:
        localStories[event.folderId].saving = false;
        localStories[event.folderId].locked = true;
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      default:
        break;
    }
  }
}
