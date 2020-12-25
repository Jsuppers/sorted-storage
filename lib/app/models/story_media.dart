/// information for media content, this could be a image, video or a document
class StoryMedia {
  // ignore: public_member_api_docs
  StoryMedia({
    this.thumbnailURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.contentSize,
  });

  /// the url for the thumbnail
  String thumbnailURL;

  /// if this media is a video
  bool isVideo;

  /// if this media is a document
  bool isDocument;

  /// content size of this media
  int contentSize;

  /// byte stream of this media
  Stream<List<int>> stream;
}
