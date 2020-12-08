import 'package:web/app/models/adventure.dart';
import 'package:web/ui/widgets/timeline_card.dart';

enum TimelineMessageType {
  initial_state,
  update_drive,
  retrieve_stories,
  retrieve_story,
  create_story,
  progress_upload,
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
  delete_story,
  updated_stories,
  syncing_story_start,
  syncing_story_end,
  syncing_story_state,
  uploading_comments_start,
  uploading_comments_finished,
}

class TimelineState {
  final String folderID;
  final Map<String, TimelineData> stories;
  final TimelineMessageType type;
  final List<AdventureComment> comments;
  final Map<String, List<String>> uploadingImages;
  final dynamic data;
  const TimelineState(this.type, this.stories, {this.data, this.comments,this.folderID, this.uploadingImages});
}
