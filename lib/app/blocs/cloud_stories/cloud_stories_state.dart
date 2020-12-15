import 'package:web/ui/widgets/timeline_card.dart';

enum CloudStoriesType {
  initial_state,
  new_user,
  retrieve_stories,
  retrieve_story,
  create_story,
  progress_upload,
  updated_stories,
  syncing_story_start,
  syncing_story_end,
  syncing_story_state,
  delete_story
}

class CloudStoriesState {
  final CloudStoriesType type;
  final Map<String, TimelineData> cloudStories;
  final dynamic data;
  final String folderID;

  const CloudStoriesState(this.type, this.cloudStories, {this.data, this.folderID});
}
