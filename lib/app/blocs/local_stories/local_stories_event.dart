import 'package:web/app/blocs/local_stories/local_stories_type.dart';

/// Event for the LocalStoriesBloc
class LocalStoriesEvent {
  /// The constructor requires a LocalStories type
  const LocalStoriesEvent(this.type,
      {this.data, this.parentID, this.folderID});

  /// represents which story this event is for, this can also be a sub event
  final String folderID;

  /// usually set to the main story folderID, used to find a sub folder
  final String parentID;

  /// used to tell the bloc which type of event this is
  final LocalStoriesType type;

  /// data which the bloc will read
  final dynamic data;
}
