import 'package:web/app/models/story_comments.dart';

/// response from sending a comment
class CommentsResponse {
  // ignore: public_member_api_docs
  CommentsResponse({required this.comments, this.commentsID});

  /// all the comments
  final StoryComments comments;

  /// folder ID for the comments file
  final String? commentsID;
}
