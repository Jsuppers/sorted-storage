import 'package:web/app/blocs/local_stories/local_stories_state.dart';

class LocalStoriesEvent {
  final String folderId;
  final LocalStoriesType type;
  final String parentId;
  final dynamic data;

  const LocalStoriesEvent(this.type,
      {this.data, this.parentId, this.folderId});
}
