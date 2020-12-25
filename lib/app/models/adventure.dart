/// AdventureComment holds a comment from a user
class AdventureComment {
  /// constructor which sets default values
  AdventureComment({this.user = '', this.comment = ''});
  static AdventureComment fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return AdventureComment();
    }

    String user = '';
    String comment = '';
    if (json.containsKey('u')) {
      user = json['u'] as String;
    }
    if (json.containsKey('c')) {
      comment = json['c'] as String;
    }

    return AdventureComment(user: user, comment: comment);
  }

  String user;
  String comment;

  Map<String, dynamic> toJson() {
    return {'u': user, 'c': comment};
  }
}

class AdventureComments {
  AdventureComments({this.comments}) {
    this.comments ??= <AdventureComment>[];
  }
  AdventureComments.clone(AdventureComments comment)
      : this(comments: List.from(comment.comments));

  List<AdventureComment> comments;

  static AdventureComments fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return AdventureComments();
    }
    final List<AdventureComment> comments = <AdventureComment>[];
    if (json.containsKey('c')) {
      for (dynamic comment in json['c']) {
        comments
            .add(AdventureComment.fromJson(comment as Map<String, dynamic>));
      }
    }

    AdventureComments(comments: comments);
  }

  Map<String, dynamic> toJson() {
    return {
      'c': comments,
    };
  }
}

class AdventureSettings {
  AdventureSettings({this.title = '', this.description = '', this.emoji = ''});

  static AdventureSettings fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return AdventureSettings();
    }

    String title = '';
    String description = '';
    String emoji = '';
    if (json.containsKey('t')) {
      title = json['t'] as String;
    }
    if (json.containsKey('d')) {
      description = json['d'] as String;
    }
    if (json.containsKey('e')) {
      emoji = json['e'] as String;
    }

    return AdventureSettings(
        title: title, description: description, emoji: emoji);
  }

  String emoji;
  String title;
  String description;

  Map<String, dynamic> toJson() {
    return {'t': title, 'd': description, 'e': emoji};
  }
}
