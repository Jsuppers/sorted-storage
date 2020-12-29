import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/story_comments.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/timeline_service.dart';

/// LocalStoriesBloc handles all the local changes of the timeline. This allows
/// the user to easily edit and reset the state of the timeline
class LocalStoriesBloc extends Bloc<LocalStoriesEvent, LocalStoriesState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  LocalStoriesBloc({@required Map<String, StoryTimelineData> localStories})
      : super(LocalStoriesState(LocalStoriesType.initialState, localStories)) {
    _localStories = localStories;
  }

  Map<String, StoryTimelineData> _localStories;

  @override
  Stream<LocalStoriesState> mapEventToState(LocalStoriesEvent event) async* {
    switch (event.type) {
      case LocalStoriesType.cancelStory:
        _localStories[event.folderID] = StoryTimelineData.clone(
            event.data[event.folderID] as StoryTimelineData);
        _localStories[event.folderID].locked = true;
        yield LocalStoriesState(LocalStoriesType.cancelStory, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.editStory:
        _localStories[event.folderID].locked = false;
        yield LocalStoriesState(LocalStoriesType.editStory, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.editDescription:
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.description = event.data as String;
        break;
      case LocalStoriesType.editTitle:
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.title = event.data as String;
        break;
      case LocalStoriesType.editTimestamp:
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.timestamp = event.data as int;
        break;
      case LocalStoriesType.addImage:
        final StoryContent eventContent = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        FilePicker.platform
            .pickFiles(
                type: FileType.media, allowMultiple: true, withReadStream: true)
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
                    contentSize: element.size,
                    isVideo: mime.startsWith('video/'),
                    isDocument: !mime.startsWith('video/') &&
                        !mime.startsWith('image/')));
          }
          add(LocalStoriesEvent(LocalStoriesType.pickedImage,
              folderID: event.folderID));
          return file;
        });

        break;
      case LocalStoriesType.createSubStory:
        final StoryTimelineData story = _localStories[event.parentID];
        story.subEvents.add(StoryContent(
          folderID: TimelineService.createUniqueTempStoryName(event.parentID),
          timestamp: story.mainStory.timestamp,
          comments: StoryComments(),
        ));
        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.deleteSubStory:
        final StoryTimelineData story = _localStories[event.parentID];
        story.subEvents.removeWhere(
            (StoryContent element) => element.folderID == event.folderID);
        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
            folderID: event.parentID);
        break;
      case LocalStoriesType.deleteImage:
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.images.remove(event.data);
        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.editEmoji:
        final StoryContent eventData = TimelineService.getStoryWithFolderID(
            event.parentID, event.folderID, _localStories);
        eventData.emoji = event.data as String;
        yield LocalStoriesState(LocalStoriesType.editEmoji, _localStories,
            folderID: event.folderID, data: event.data);
        break;
      case LocalStoriesType.pickedImage:
        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
            folderID: event.folderID);
        break;
      case LocalStoriesType.updateUI:
        _localStories[event.folderID].saving = false;
        _localStories[event.folderID].locked = true;
        yield LocalStoriesState(LocalStoriesType.updateUI, _localStories,
            folderID: event.folderID);
        break;
      default:
        break;
    }
  }
}
