// Project imports:
import 'package:web/app/blocs/comment_handler/comment_handler_type.dart';

/// event to send comments
class CommentHandlerEvent {
  /// creates the event
  CommentHandlerEvent(this.type, {this.folderID, this.data});

  /// the type of event
  final CommentHandlerType? type;

  /// folder ID is the stories folder ID
  final String? folderID;

  /// data which is passed in the event
  final dynamic data;
}
