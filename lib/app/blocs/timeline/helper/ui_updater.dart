import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class UIUpdater {
  Map<String, TimelineData> localStories;

  UIUpdater(this.localStories);

  Stream<TimelineState> updateUI(TimelineEvent event) async* {
    switch (event.type) {
      case TimelineMessageType.updated_stories:
        yield TimelineState(TimelineMessageType.updated_stories, localStories);
        break;
      case TimelineMessageType.syncing_story_end:
        localStories[event.folderId].saving = false;
        localStories[event.folderId].locked = true;
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      case TimelineMessageType.syncing_story_state:
        yield TimelineState(
            TimelineMessageType.syncing_story_state, localStories,
            folderID: event.folderId, data: event.data);
        break;
      case TimelineMessageType.progress_upload:
        yield TimelineState(TimelineMessageType.progress_upload, localStories,
            folderID: event.folderId, data: event.data);
        break;
      case TimelineMessageType.picked_image:
        yield TimelineState(TimelineMessageType.syncing_story_end, localStories,
            folderID: event.folderId);
        break;
      default:
        break;
    }
  }

}
