import 'package:web/ui/widgets/timeline_card.dart';

enum LocalStoriesType {
  initial_state,
  picked_image,
  create_sub_story,
  delete_sub_story,
  edit_timestamp,
  edit_description,
  edit_emoji,
  edit_title,
  delete_image,
  add_image,
  cancel_story,
  edit_story,
  syncing_story_end,
}

class LocalStoriesState {
  final LocalStoriesType type;
  final Map<String, TimelineData> localStories;
  final dynamic data;
  final String folderID;
  const LocalStoriesState(this.type, this.localStories, {this.data, this.folderID});
}
