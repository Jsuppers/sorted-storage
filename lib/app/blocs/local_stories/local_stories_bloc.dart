import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class LocalStoriesBloc extends Bloc<LocalStoriesEvent, LocalStoriesState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  LocalStoriesBloc({@required Map<String, TimelineData> localStories})
      : super(LocalStoriesState(LocalStoriesType.initial_state, localStories)){
    _localStories = localStories;
  }

  Map<String, TimelineData> _localStories;

  @override
  Stream<LocalStoriesState> mapEventToState(LocalStoriesEvent event) async* {
    switch (event.type) {
      case LocalStoriesType.cancel_story:
        _localStories[event.folderID] =
            TimelineData.clone(event.data[event.folderID] as TimelineData);
        _localStories[event.folderID].locked = true;
        yield LocalStoriesState(LocalStoriesType.cancel_story, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.edit_story:
        _localStories[event.folderID].locked = false;
        yield LocalStoriesState(LocalStoriesType.edit_story, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.edit_description:
        final StoryContent eventData = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.description = event.data as String;
        break;
      case LocalStoriesType.edit_title:
        final StoryContent eventData = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.title = event.data as String;
        break;
      case LocalStoriesType.edit_timestamp:
        final StoryContent eventData = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.timestamp = event.data as int;
        break;
      case LocalStoriesType.add_image:
        final StoryContent eventContent = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        try {
          FilePicker.platform
              .pickFiles(
                  type: FileType.media,
                  allowMultiple: true,
                  withReadStream: true)
              .then((FilePickerResult file) {
            if (file == null || file.files == null || file.files.isEmpty) {
              return file;
            }
            for (int i = 0; i < file.files.length; i++) {
              final PlatformFile element = file.files[i];
              final String mime = lookupMimeType(element.name);
              eventContent.images.putIfAbsent(
                  element.name,
                  () => StoryMedia(
                      stream: element.readStream,
                      size: element.size,
                      isVideo: mime.startsWith('video/'),
                      isDocument: !mime.startsWith('video/') &&
                          !mime.startsWith('image/')));
            }
            add(LocalStoriesEvent(LocalStoriesType.picked_image,
                folderID: event.folderID));
            return file;
          });
        } catch (e) {
          print(e);
        }

        break;
      case LocalStoriesType.create_sub_story:
        final TimelineData story = _localStories[event.parentID];
        story.subEvents.add(StoryContent(
          folderID: TimelineService.createUniqueTempName(event.parentID),
          timestamp: story.mainStory.timestamp,
          comments: AdventureComments(),
        ));
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.delete_sub_story:
        final TimelineData story = _localStories[event.parentID];
        story.subEvents.removeWhere(
            (StoryContent element) => element.folderID == event.folderID);
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, _localStories,
            folderID: event.parentID);
        break;
      case LocalStoriesType.delete_image:
        final StoryContent eventData = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.images.remove(event.data);
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.edit_emoji:
        final StoryContent eventData = TimelineService.getEventWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.emoji = event.data as String;
        yield LocalStoriesState(LocalStoriesType.edit_emoji, _localStories,
            folderID: event.folderID, data: event.data);
        break;
      case LocalStoriesType.picked_image:
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.syncing_story_end:
        _localStories[event.folderID].saving = false;
        _localStories[event.folderID].locked = true;
        yield LocalStoriesState(
            LocalStoriesType.syncing_story_end, _localStories,
            folderID: event.folderID);
        break;
      default:
        break;
    }
  }
}
