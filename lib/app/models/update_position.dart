class UpdatePosition {
  UpdatePosition(
      {
        required this.folderID,
        required this.currentIndex,
      required this.targetIndex,
      required this.items,
        required this.metadata,
      this.media});

  int currentIndex;
  int targetIndex;
  bool? media;
  List<dynamic> items;
  String folderID;
  Map<String, dynamic> metadata;
}
