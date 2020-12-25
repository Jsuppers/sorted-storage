/// StoryComment holds a comment from a user
class StoryComment {
  /// constructor which sets default values
  StoryComment({this.user = '', this.comment = ''});
  // ignore: public_member_api_docs, prefer_constructors_over_static_methods
  static StoryComment fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return StoryComment();
    }

    String user = '';
    String comment = '';
    if (json.containsKey('u')) {
      user = json['u'] as String;
    }
    if (json.containsKey('c')) {
      comment = json['c'] as String;
    }

    return StoryComment(user: user, comment: comment);
  }

  /// the user which sent the comment
  String user;

  /// content of the comment
  String comment;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'u': user, 'c': comment};
  }
}
