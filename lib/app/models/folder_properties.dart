
class FolderProperties {
  FolderProperties({
    required this.id,
    required this.emoji,
    required this.title,
    required this.order,
  });

  static FolderProperties? extractProperties(String folderName, String id) {
    try {
      final List<String> splitName = folderName.split('_');
      if(splitName.length == 1) {
        return FolderProperties(
          emoji: '',
          order: 0,
          title: folderName,
          id: id,
        );
      }
      return FolderProperties(
          emoji: splitName[0],
          order: int.parse(splitName[1]),
          title: splitName[2],
          id: id,
      );
    } catch (e) {
      return null;
    }
  }

  String format(int order) {
    return "'$emoji'_'$id'_'$order'_'$title'";
  }

  /// id for this settings file
  late String id;

  /// a emoji for this story
  late String emoji;

  /// the title for this story
  late String title;

  late int order;
}
