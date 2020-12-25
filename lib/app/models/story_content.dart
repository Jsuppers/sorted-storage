import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/sub_event.dart';

class StoryContent {
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
    this.images ??= Map<String, StoryMedia>();
    this.subEvents ??= <SubEvent>[];
    this.comments ??= AdventureComments();
  }

  int timestamp;
  String emoji;
  String title;
  Map<String, StoryMedia> images;
  String description;
  String folderID;
  String settingsID;
  String commentsID;
  String permissionID;
  AdventureComments comments;
  List<SubEvent> subEvents;

  StoryContent.clone(StoryContent event)
      : this(
      timestamp: event.timestamp,
      title: event.title,
      emoji: event.emoji,
      images: Map.from(event.images),
      description: event.description,
      settingsID: event.settingsID,
      commentsID: event.commentsID,
      folderID: event.folderID,
      subEvents: List.from(event.subEvents),
      comments: AdventureComments.clone(event.comments));
}
