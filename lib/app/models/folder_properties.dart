import 'dart:developer';

class FolderProperties {
  FolderProperties({
    this.id,
    required this.emoji,
    required this.title,
    this.order,
  }) {
    if (this.order == null) {
      this.order = DateTime.now().millisecondsSinceEpoch.toDouble();
    }
  }

  static FolderProperties extractProperties(String folderName,
      {String? id, double? order}) {
    final List<String> splitName = folderName.split(' ');
    if (splitName.length == 1) {
      return FolderProperties(
        emoji: '',
        title: folderName,
        id: id,
        order: order,
      );
    }
    String emoji = splitName[0];
    String title = splitName.skip(1).join(' ');
    return FolderProperties(
      emoji: emoji,
      title: title,
      id: id,
      order: order,
    );
  }

  /// id for this settings file
  late String? id;

  /// a emoji for this story
  late String emoji;

  /// the title for this story
  late String title;

  double? order;
}
