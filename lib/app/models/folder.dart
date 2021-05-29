// Project imports:
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/folder_media.dart';

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

  static String toFileName(Folder folder) {
    return '${folder.emoji} ${folder.title}';
  }
}

/// content for a story
class Folder {
  // ignore: public_member_api_docs
  Folder({
    this.id,
    this.amOwner,
    this.parent,
    required this.title,
    required this.emoji,
    Map<String, FolderMedia>? images,
    Map<String, dynamic>? metadata,
    List<Folder>? subFolders,
  }) {
    if (subFolders != null) {
      this.subFolders = subFolders;
    }
    if (metadata != null) {
      this.metadata = metadata;
    }
    if (images != null) {
      this.images = images;
    }
  }

  static Folder createFromFolderName(
      {required String? folderName,
      required String id,
      Map<String, dynamic>? metadata,
      Folder? parent,
      bool? owner}) {
    folderName ??= '';
    final FolderNameData fileName = FolderNameData.fromFileName(folderName);
    return Folder(
      emoji: fileName.emoji,
      title: fileName.title,
      id: id,
      metadata: metadata,
      amOwner: owner,
      parent: parent,
    );
  }

  static void sortFolders(List<Folder>? folders) {
    if (folders == null) {
      return;
    }
    folders.sort((Folder a, Folder b) {
      final double first = a.metadata.getTimestamp() ?? 0;
      final double second = b.metadata.getTimestamp() ?? 0;
      return first.compareTo(second);
    });
  }

  /// clones a story content
  Folder.clone(Folder event)
      : title = event.title,
        emoji = event.emoji,
        metadata = Map<String, dynamic>.from(event.metadata),
        images = Map<String, FolderMedia>.from(
            event.images.map((String key, FolderMedia value) {
          return MapEntry<String, FolderMedia>(key, FolderMedia.clone(value));
        })),
        id = event.id,
        amOwner = event.amOwner,
        isRootFolder = event.isRootFolder,
        parent = event.parent,
        subFolders = List<Folder>.from(event.subFolders);

  /// the folder ID of this doler
  String? id;

  /// a emoji for this folder
  String emoji;

  /// the title for this folder
  String title;

  bool loaded = false;

  bool isRootFolder = false;

  Folder? parent;

  /// if the current user is the owner of the folder
  bool? amOwner;

  Map<String, dynamic> metadata = <String, dynamic>{};

  /// images on the main story
  Map<String, FolderMedia> images = <String, FolderMedia>{};

  List<Folder> subFolders = <Folder>[];
}
