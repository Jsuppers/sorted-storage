import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';

/// Event for the CloudStoriesBloc
class CloudStoriesEvent {
  /// The constructor requires a CloudStories type
  const CloudStoriesEvent(this.type,
      {this.data, this.parentID, this.mainEvent, this.folderID});

  /// represents which story this event is for, this can also be a sub event
  final String folderID;

  /// usually set to the main story folderID, used to find a sub folder
  final String parentID;

  /// used to tell the bloc which type of event this is
  final CloudStoriesType type;

  /// flag to indicate if this is a main event
  final bool mainEvent;

  /// data which the bloc will read
  final dynamic data;

}
