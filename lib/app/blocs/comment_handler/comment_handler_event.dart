import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentHandlerEvent {
  final CommentHandlerType type;
  final String folderId;
  final dynamic data;
  final Map<String, TimelineData> localStories;

  CommentHandlerEvent(this.type, {this.folderId, this.data, this.localStories});
}
