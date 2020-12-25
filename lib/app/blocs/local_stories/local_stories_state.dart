import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// State returned
class LocalStoriesState {
  /// The state contains the type of state and a copy of the current timeline
  const LocalStoriesState(this.type, this.localStories,
      {this.data, this.folderID});

  /// type of state
  final LocalStoriesType type;

  /// local copy of the timeline
  final Map<String, TimelineData> localStories;

  /// data returned from the state
  final dynamic data;

  /// the folder ID for the related story
  final String folderID;

}
