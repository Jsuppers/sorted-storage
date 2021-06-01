// Project imports:
import 'package:web/app/models/folder.dart';

/// service for various functions regarding the timeline
class TimelineService {
  /// Retrieves a folder with the given folder ID
  static Folder? getFolderWithID(String folderID, Folder? folder) {
    if (folder == null) {
      return null;
    }
    if (folder.id == folderID) {
      return folder;
    } else {
      for (int i = 0; i < folder.subFolders.length; i++) {
        final Folder element = folder.subFolders[i];
        final Folder? subFolder = getFolderWithID(folderID, element);
        if (subFolder != null) {
          return subFolder;
        }
      }
    }
    return null;
  }
}
