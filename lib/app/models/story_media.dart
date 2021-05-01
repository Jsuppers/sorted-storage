/// information for media content, this could be a image, video or a document
class StoryMedia {
  // ignore: public_member_api_docs
  StoryMedia({
    required this.id,
    this.thumbnailURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.contentSize,
    this.order,
    required this.name,
    this.retrieveThumbnail = false,
  }) {
    order ??= DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  /// clone the media file
  StoryMedia.clone(StoryMedia media)
      : thumbnailURL = media.thumbnailURL,
        stream = media.stream,
        isVideo = media.isVideo,
        isDocument = media.isDocument,
        contentSize = media.contentSize,
        retrieveThumbnail = media.retrieveThumbnail,
        id = media.id,
        name = media.name,
        order = media.order;

  /// and index which will ensure the media without an index will be at the end
  /// of the list hopefully no one uploads this much media in one story..
  static const int highIntValue = 65536;

  /// name of the file
  String name;

  /// id of this file
  String id;

  /// the url for the thumbnail
  String? thumbnailURL;

  /// if this media is a video
  bool isVideo;

  /// should retrieve the thumbnail
  bool retrieveThumbnail;

  /// if this media is a document
  bool isDocument;

  /// content size of this media
  int? contentSize;

  /// byte stream of this media
  Stream<List<int>>? stream;

  /// index of this media
  double? order;
}
