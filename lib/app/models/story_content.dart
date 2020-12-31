import 'package:web/app/models/story_comments.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/sub_event.dart';

/// content for a story
class StoryContent {
  // ignore: public_member_api_docs
  StoryContent(
      {this.timestamp,
      this.title = '',
      this.emoji = '',
      this.images,
      this.description = '',
      this.folderID,
      this.settingsID,
      this.subEvents,
      this.commentsID,
      this.comments}) {
    images ??= <String, StoryMedia>{};
    subEvents ??= <SubEvent>[];
    comments ??= StoryComments();
  }

  /// clones a story content
  StoryContent.clone(StoryContent event)
      : timestamp = event.timestamp,
        title = event.title,
        emoji = event.emoji,
        images = Map<String, StoryMedia>.from(
            event.images.map((String key, StoryMedia value) {
          return MapEntry<String, StoryMedia>(key, StoryMedia.clone(value));
        })),
        description = event.description,
        settingsID = event.settingsID,
        commentsID = event.commentsID,
        folderID = event.folderID,
        subEvents = List<SubEvent>.from(event.subEvents),
        comments = StoryComments.clone(event.comments);

  /// timestamp of the story
  int timestamp;

  /// a small emoji for the story
  String emoji;

  /// the title of the story
  String title;

  /// images on the main story
  Map<String, StoryMedia> images;

  /// the description of the story
  String description;

  /// the folder ID of this story
  String folderID;

  /// the file ID of the settings file
  String settingsID;

  /// the file ID of the comments file
  String commentsID;

  /// the ID of the permission for this story
  String permissionID;

  /// comments for this story
  StoryComments comments;

  /// a list of all the sub events for this story
  List<SubEvent> subEvents;
}
