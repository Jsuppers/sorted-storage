// Project imports:
import 'package:web/app/models/folder_content.dart';

/// service for various functions regarding the timeline
class TimelineService {
  /// Retrieves a story with the given folder ID
  static FolderContent? getFolderWithID(
      String folderID, FolderContent? folder) {
    if (folder == null) {
      return null;
    }
    if (folder.id == folderID) {
      return folder;
    } else {
      for (int i = 0;
          folder.subFolders != null && i < folder.subFolders!.length;
          i++) {
        final FolderContent element = folder.subFolders![i];
        final FolderContent? subFolder = getFolderWithID(folderID, element);
        if (subFolder != null) {
          return subFolder;
        }
      }
    }
    return null;
  }
}
