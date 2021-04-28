// Project imports:
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/timeline_data.dart';

/// State returned
class LocalStoriesState {
  /// The state contains the type of state and a copy of the current timeline
  const LocalStoriesState(this.type, this.localStories,
      {this.data, this.folderID});

  /// type of state
  final LocalStoriesType type;

  /// local copy of the timeline
  final Map<String, StoryTimelineData> localStories;

  /// data returned from the state
  final dynamic data;

  /// the folder ID for the related story
  final String? folderID;
}
