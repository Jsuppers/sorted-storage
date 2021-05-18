// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';

/// Event for the CloudStoriesBloc
class CloudStoriesEvent {
  /// The constructor requires a CloudStories type
  const CloudStoriesEvent(this.type,
      {this.parentID, this.folderID, this.error, this.data});

  /// used to tell the bloc which type of event this is
  final CloudStoriesType type;

  /// generic data passed in the event
  final dynamic data;

  /// represents which story this event is for, this can also be a sub event
  final String? folderID;

  /// usually set to the main story folderID, used to find a sub folder
  final String? parentID;

  /// error message to pass on to the front end
  final String? error;
}
