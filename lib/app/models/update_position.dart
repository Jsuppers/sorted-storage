class UpdatePosition {
  UpdatePosition(
      {required this.currentIndex,
      required this.targetIndex,
      required this.items,
      this.media});

  int currentIndex;
  int targetIndex;
  bool? media;
  List<dynamic> items;
}
