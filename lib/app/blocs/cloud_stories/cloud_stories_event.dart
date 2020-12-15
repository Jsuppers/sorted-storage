
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';

class CloudStoriesEvent {
  final String folderId;
  final CloudStoriesType type;
  final String parentId;
  final bool mainEvent;
  final dynamic data;

  const CloudStoriesEvent(this.type,
      {this.data, this.parentId, this.mainEvent, this.folderId});
}
