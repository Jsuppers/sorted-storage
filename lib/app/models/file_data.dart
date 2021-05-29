/// information for media content, this could be a image, video or a document
class FileData {
  // ignore: public_member_api_docs
  FileData({
    required this.id,
    this.thumbnailURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.contentSize,
    Map<String, dynamic>? metadata,
    required this.name,
    this.retrieveThumbnail = false,
  }) {
    if (metadata != null) {
      this.metadata = metadata;
    }
  }

  /// clone the media file
  FileData.clone(FileData media)
      : thumbnailURL = media.thumbnailURL,
        stream = media.stream,
        isVideo = media.isVideo,
        isDocument = media.isDocument,
        contentSize = media.contentSize,
        retrieveThumbnail = media.retrieveThumbnail,
        id = media.id,
        name = media.name,
        metadata = Map<String, dynamic>.from(media.metadata);

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
  Map<String, dynamic> metadata = <String, dynamic>{};
}
