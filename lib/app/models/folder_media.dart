import 'package:flutter/foundation.dart';
import 'package:web/app/models/folder_metadata.dart';

/// information for media content, this could be a image, video or a document
class FolderMedia {
  // ignore: public_member_api_docs
  FolderMedia({
    required this.id,
    this.thumbnailURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.contentSize,
    this.metadata,
    required this.name,
    this.retrieveThumbnail = false,
  }) {
    metadata ??= <String, dynamic>{};
  }

  /// clone the media file
  FolderMedia.clone(FolderMedia media)
      : thumbnailURL = media.thumbnailURL,
        stream = media.stream,
        isVideo = media.isVideo,
        isDocument = media.isDocument,
        contentSize = media.contentSize,
        retrieveThumbnail = media.retrieveThumbnail,
        id = media.id,
        name = media.name,
        metadata = media.metadata;

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
  Map<String, dynamic>? metadata;

  double? getTimestamp() {
    return metadata?[describeEnum(MetadataKeys.timestamp)] as double?;
  }

  void setTimestamp(double? timestamp) {
    if (timestamp == null) {
      return;
    }
    metadata?[describeEnum(MetadataKeys.timestamp)] = timestamp;
  }

  String? getDescription() {
    return metadata?[describeEnum(MetadataKeys.description)] as String?;
  }

  void setDescription(String? description) {
    metadata?[describeEnum(MetadataKeys.description)] = description;
  }
}
