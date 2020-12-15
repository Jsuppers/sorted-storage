import 'package:web/app/models/adventure.dart';

class CommentsResponse {
  final AdventureComments comments;
  final String commentsID;

  CommentsResponse({this.comments, this.commentsID});
}
