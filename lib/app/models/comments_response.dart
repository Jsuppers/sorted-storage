import 'package:web/app/models/adventure.dart';

/// response from sending a comment
class CommentsResponse {
  // ignore: public_member_api_docs
  CommentsResponse({this.comments, this.commentsID});

  /// all the comments
  final AdventureComments comments;

  /// folder ID for the comments file
  final String commentsID;

}
