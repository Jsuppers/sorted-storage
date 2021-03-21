/// various settings for a story
class StoryMetadata {
  // ignore: public_member_api_docs
  StoryMetadata(
      {this.id, this.title = '', this.description = '', this.emoji = ''});

  // ignore: public_member_api_docs, prefer_constructors_over_static_methods
  static StoryMetadata fromJson(String id, Map<String, dynamic> json) {
    if (json == null) {
      return StoryMetadata();
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

    return StoryMetadata(
        id: id, title: title, description: description, emoji: emoji);
  }

  StoryMetadata.clone(StoryMetadata metadata)
      : id = metadata.id,
        title = metadata.title,
        description = metadata.description,
        emoji = metadata.emoji;

  /// id for this settings file
  String id;

  /// a emoji for this story
  String emoji;

  /// the title for this story
  String title;

  /// a description for this story
  String description;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'t': title, 'd': description, 'e': emoji};
  }
}
