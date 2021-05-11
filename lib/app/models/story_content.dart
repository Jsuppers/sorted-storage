// Project imports:
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';

/// content for a story
class FolderContent {
  // ignore: public_member_api_docs
  FolderContent(
      {this.id,
      this.order,
      required this.title,
      required this.emoji,
      this.images,
      this.permissionID,
      this.metadata,
      this.subFolders}) {
    images ??= <String, StoryMedia>{};
    metadata ??= FolderMetadata();
    order ??= DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  static FolderContent createFromFolderName({required String? folderName, double? order, required String id}){
    folderName ??= '';
    final List<String> splitName = folderName.split(' ');
    if (splitName.length == 1) {
      return FolderContent(
        emoji: '',
        title: folderName,
        id: id,
        order: order,
      );
    }
    String emoji = splitName[0];
    String title = splitName.skip(1).join(' ');
    return FolderContent(
      emoji: emoji,
      title: title,
      id: id,
      order: order,
    );
  }

  /// clones a story content
  FolderContent.clone(FolderContent event)
      : order = event.order,
        title = event.title,
        emoji = event.emoji,
        permissionID = event.permissionID,
        metadata = FolderMetadata.clone(event.metadata!),
        images = Map<String, StoryMedia>.from(
            event.images!.map((String key, StoryMedia value) {
          return MapEntry<String, StoryMedia>(key, StoryMedia.clone(value));
        })),
        id = event.id,
        subFolders = List<FolderContent>.from(event.subFolders!);



  /// the folder ID of this doler
  String? id;

  /// a emoji for this folder
  String emoji;

  /// the title for this folder
  String title;

  double? order;

  bool loaded = false;

  /// the ID of the permission for this folder
  String? permissionID;

  FolderMetadata? metadata;

  /// images on the main story
  Map<String, StoryMedia>? images;

  List<FolderContent>? subFolders;
}

class InitialData {
  InitialData({required this.emoji, required this.title});
  /// a emoji for this folder
  String emoji;

  /// the title for this folder
  String title;
}

class LoadedData {

  LoadedData({required this.permissionID, required this.metadata, required this.images});

  /// the ID of the permission for this folder
  String permissionID;

  FolderMetadata metadata;

  /// images on the main story
  Map<String, StoryMedia> images;

  List<FolderContent>? subFolders;
}
