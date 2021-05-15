// Project imports:
import 'package:web/app/models/folder_content.dart';

/// service for various functions regarding the timeline
class TimelineService {
  /// Retrieves a story with the given folder ID
  static FolderContent? getFolderWithID(String folderID,
      FolderContent? folder) {
    if (folder == null) {
      return null;
    }
    if (folder.id == folderID) {
      return folder;
    } else {
      for (int i = 0; folder.subFolders != null && i < folder.subFolders!.length; i++) {
        final FolderContent element = folder.subFolders![i];
        final FolderContent? subFolder = getFolderWithID(folderID, element);
        if (subFolder != null) {
          return subFolder;
        }
      }
    }
    return null;
  }

  /// Retrieves a story with the given folder ID
  static String? getParentID(String folderID, FolderContent? folder, {String? parentID}) {
    if (parentID != null) {
      return parentID;
    }
    if (folder == null) {
      return null;
    }
    if (folder.id == folderID) {
      return parentID;
    }
    for (int i = 0; i < folder.subFolders!.length; i++) {
      final FolderContent element = folder.subFolders![i];
      final String? id = getParentID(folderID, element, parentID: parentID);
      if (id != null) {
        return id;
      }
    }
    return null;
  }
}
