class AdventureComment {
  String user;
  String comment;

  AdventureComment({this.user = "", this.comment = ""});

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

  Map<String, dynamic> toJson() {
    return {'u': user, 'c': comment};
  }
}

class AdventureComments {
  List<AdventureComment> comments;

  AdventureComments({this.comments});

  AdventureComments.clone(AdventureComments comment)
      : this(comments: List.from(comment.comments));

  static AdventureComments fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new AdventureComments(comments: []);
    }
    final List<AdventureComment> comments = [];
    if (json.containsKey('c')) {
      for (dynamic comment in json['c']) {
        comments
            .add(AdventureComment.fromJson(comment as Map<String, dynamic>));
      }
    }

    return new AdventureComments(comments: comments);
  }

  Map<String, dynamic> toJson() {
    return {
      'c': comments,
    };
  }
}

class AdventureSettings {
  String emoji;
  String title;
  String description;

  AdventureSettings({this.title = "", this.description = "", this.emoji = ""});

  static AdventureSettings fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new AdventureSettings();
    }

    String title = "";
    String description = "";
    String emoji = "";
    if (json.containsKey('t')) {
      title = json['t'] as String;
    }
    if (json.containsKey('d')) {
      description = json['d'] as String;
    }
    if (json.containsKey('e')) {
      emoji = json['e'] as String;
    }

    return new AdventureSettings(
        title: title, description: description, emoji: emoji);
  }

  Map<String, dynamic> toJson() {
    return {'t': title, 'd': description, 'e': emoji};
  }
}
