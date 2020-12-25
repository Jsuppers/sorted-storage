class StoryMedia {
  StoryMedia({
    this.imageURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.size,
  });

  String imageURL;
  bool isVideo;
  bool isDocument;
  int size;
  Stream<List<int>> stream;
}
