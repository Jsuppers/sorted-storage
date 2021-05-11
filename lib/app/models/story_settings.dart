/// various settings for a story
class FolderMetadata {
  // ignore: public_member_api_docs
  FolderMetadata(
      {this.id, this.title = '', this.description = '', this.emoji = '', this.data});

  // ignore: public_member_api_docs, prefer_constructors_over_static_methods
  static FolderMetadata fromJson(String? id, Map<String, dynamic>? json) {
    if (json == null) {
      return FolderMetadata(id: id);
    }

    String title = '';
    String description = '';
    String emoji = '';
    Map<String, dynamic>? data;
    if (json.containsKey('t')) {
      title = json['t'] as String;
    }
    if (json.containsKey('d')) {
      description = json['d'] as String;
    }
    if (json.containsKey('e')) {
      emoji = json['e'] as String;
    }
    if (json.containsKey('x')) {
      data = json['x'] as Map<String, dynamic>;
    }

    return FolderMetadata(
        id: id, title: title, description: description, emoji: emoji, data: data);
  }

  FolderMetadata.clone(FolderMetadata metadata)
      : id = metadata.id,
        title = metadata.title,
        description = metadata.description,
        emoji = metadata.emoji,
        data = Map.from(metadata.data ?? {});

  /// id for this settings file
  String? id;

  /// a emoji for this story
  String emoji;

  /// the title for this story
  String title;

  /// a description for this story
  String description;

  Map<String, dynamic>? data;

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'t': title, 'd': description, 'e': emoji, 'x': data};
  }
}
