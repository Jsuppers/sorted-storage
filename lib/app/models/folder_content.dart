// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';

class FolderNameData {
  FolderNameData({required this.emoji, required this.title});

  String emoji;
  String title;

  static FolderNameData fromFileName(String folderName) {
    final List<String> splitName = folderName.split(' ');
    if (splitName.length == 1) {
      return FolderNameData(emoji: '', title: folderName);
    }
    final String emoji = splitName[0];
    final String title = splitName.skip(1).join(' ');
    return FolderNameData(emoji: emoji, title: title);
  }

  static String toFileName(FolderContent folder) {
    return '${folder.emoji} ${folder.title}';
  }
}

/// content for a story
class FolderContent {
  // ignore: public_member_api_docs
  FolderContent({
    this.id,
    required this.owner,
    required this.title,
    required this.emoji,
    this.images,
    this.permissionID,
    this.metadata,
    this.subFolders,
  }) {
    subFolders ??= [];
    images ??= <String, FolderMedia>{};
    metadata ??= {};
  }

  static FolderContent createFromFolderName(
      {required String? folderName,
      required Map<String, dynamic>? metadata,
      required bool owner,
      required String id}) {
    folderName ??= '';
    final FolderNameData fileName = FolderNameData.fromFileName(folderName);
    return FolderContent(
      emoji: fileName.emoji,
      title: fileName.title,
      id: id,
      metadata: metadata,
      owner: owner,
    );
  }

  static void sortFolders(List<FolderContent>? folders) {
    if (folders == null) {
      return;
    }
    folders.sort((FolderContent a, FolderContent b) {
      final double first = a.getTimestamp() ?? 0;
      final double second = b.getTimestamp() ?? 0;
      return first.compareTo(second);
    });
  }

  /// clones a story content
  FolderContent.clone(FolderContent event)
      : title = event.title,
        emoji = event.emoji,
        permissionID = event.permissionID,
        metadata = Map.from(event.metadata ?? {}),
        images = Map<String, FolderMedia>.from(
            event.images!.map((String key, FolderMedia value) {
          return MapEntry<String, FolderMedia>(key, FolderMedia.clone(value));
        })),
        id = event.id,
        owner = event.owner,
        isRootFolder = event.isRootFolder,
        subFolders = List<FolderContent>.from(event.subFolders!);

  double? getTimestamp() {
    return metadata?[describeEnum(MetadataKeys.timestamp)] as double?;
  }

  void setTimestamp(double? timestamp) {
    metadata?[describeEnum(MetadataKeys.timestamp)] = timestamp;
  }

  String? getDescription() {
    return metadata?[describeEnum(MetadataKeys.description)] as String?;
  }

  void setDescription(String? description) {
    metadata?[describeEnum(MetadataKeys.description)] = description;
  }

  /// the folder ID of this doler
  String? id;

  /// a emoji for this folder
  String emoji;

  /// the title for this folder
  String title;

  bool loaded = false;

  bool isRootFolder = false;

  /// the ID of the permission for this folder
  String? permissionID;

  bool owner;

  Map<String, dynamic>? metadata;

  /// images on the main story
  Map<String, FolderMedia>? images;

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
  LoadedData(
      {required this.permissionID,
      required this.metadata,
      required this.images});

  /// the ID of the permission for this folder
  String permissionID;

  Map<String, dynamic> metadata;

  /// images on the main story
  Map<String, FolderMedia> images;

  List<FolderContent>? subFolders;
}
