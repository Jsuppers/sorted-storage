import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/timeline_data.dart';

/// State returned
class CloudStoriesState {
  /// The state contains the type of state and a copy of the cloud timeline
  const CloudStoriesState(this.type, this.cloudStories,
      {this.storyTimelineData, this.folderID, this.error});

  /// type of state
  final CloudStoriesType type;

  /// cloud copy of the timeline
  final Map<String, StoryTimelineData> cloudStories;

  /// data returned from the state
  final StoryTimelineData storyTimelineData;

  /// the folder ID for the related story
  final String folderID;

  /// error message
  final String error;
}
