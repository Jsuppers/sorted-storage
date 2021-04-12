import 'package:web/app/models/story_comment.dart';

/// all comments for a story
class StoryComments {
  // ignore: public_member_api_docs
  StoryComments({this.comments}) {
    comments ??= <StoryComment>[];
  }

  /// clone the list of comments
  StoryComments.clone(StoryComments comment)
      : comments = List<StoryComment>.from(comment.comments);

  // ignore: public_member_api_docs, prefer_constructors_over_static_methods
  static StoryComments fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return StoryComments();
    }
    final List<StoryComment> comments = <StoryComment>[];
    if (json.containsKey('c')) {
      for (final dynamic comment in json['c']) {
        comments.add(StoryComment.fromJson(comment as Map<String, dynamic>));
      }
    }

    return StoryComments(comments: comments);
  }

  /// list of all comments
  List<StoryComment> comments;

  /// convert comments to json file
  Map<String, dynamic> toJson() {
    // ignore: always_specify_types
    return {
      'c': comments,
    };
  }
}
