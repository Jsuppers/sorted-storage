// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';

/// State returned
class CloudStoriesState {
  /// The state contains the type of state and a copy of the cloud timeline
  const CloudStoriesState(this.type, {this.folderID, this.error, this.data});

  /// type of state
  final CloudStoriesType type;

  /// generic data passed in the state
  final dynamic data;

  /// the folder ID for the related story
  final String? folderID;

  /// error message
  final String? error;
}
