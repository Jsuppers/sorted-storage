// Project imports:
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';

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

  /// Removes a image with the given key
  static bool removeImage(String imageKey, FolderContent? folder) {
    if (folder == null || folder.images == null) {
      return false;
    }
    if (folder.images!.containsKey(imageKey)) {
      folder.images!.removeWhere((String key, _) => key == imageKey);
      return true;
    } else {
      for (int i = 0; i < folder.subFolders!.length; i++) {
        final FolderContent element = folder.subFolders![i];
        if (removeImage(imageKey, element)) {
          return true;
        }
      }
    }
    return false;
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
