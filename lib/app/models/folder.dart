// Project imports:
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/file_data.dart';

enum FolderTypes {
  /// standard and default layout which shows the folders in a timeline layout
  basic,

  /// a custom layout
  custom,
}

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

/// content for a folder
class Folder {

  // ignore: public_member_api_docs
  Folder({
    this.id,
    this.amOwner,
    this.parent,
    required this.title,
    required this.emoji,
    Map<String, FileData>? files,
    Map<String, dynamic>? metadata,
    List<Folder>? subFolders,
  }) {
    if (subFolders != null) {
      this.subFolders = subFolders;
    }
    if (metadata != null) {
      this.metadata = metadata;
    }
    this.metadata.setTimestampIfEmpty(DateTime.now().millisecondsSinceEpoch);
    this.metadata.setOrderIfEmpty(DateTime.now().millisecondsSinceEpoch.toDouble());
    if (files != null) {
      this.files = files;
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
      final int first = a.metadata.getTimestamp() ?? 0;
      final int second = b.metadata.getTimestamp() ?? 0;
      return first.compareTo(second);
    });
  }

  /// clones a folder's content
  Folder.clone(Folder event)
      : title = event.title,
        emoji = event.emoji,
        metadata = Map<String, dynamic>.from(event.metadata),
        files = Map<String, FileData>.from(
            event.files.map((String key, FileData value) {
          return MapEntry<String, FileData>(key, FileData.clone(value));
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

  Map<String, FileData> files = <String, FileData>{};

  List<Folder> subFolders = <Folder>[];
}
