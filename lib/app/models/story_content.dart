// Project imports:
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/sub_event.dart';

/// content for a story
class StoryContent {
  // ignore: public_member_api_docs
  StoryContent(
      {required this.timestamp,
      this.images,
      required this.folderID,
      this.metadata,
      this.subEvents}) {
    images ??= <String, StoryMedia>{};
    subEvents ??= <SubEvent>[];
    metadata ??= StoryMetadata();
  }

  /// clones a story content
  StoryContent.clone(StoryContent event)
      : timestamp = event.timestamp,
        metadata = StoryMetadata.clone(event.metadata!),
        images = Map<String, StoryMedia>.from(
            event.images!.map((String key, StoryMedia value) {
          return MapEntry<String, StoryMedia>(key, StoryMedia.clone(value));
        })),
        folderID = event.folderID,
        subEvents = List<SubEvent>.from(event.subEvents!);

  StoryMetadata? metadata;

  /// timestamp of the story
  int timestamp;

  /// images on the main story
  Map<String, StoryMedia>? images;

  /// the folder ID of this story
  String folderID;

  /// the ID of the permission for this story
//  String permissionID;

  /// a list of all the sub events for this story
  List<SubEvent>? subEvents;
}
