// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';

/// Event for the CloudStoriesBloc
class FolderStorageEvent {
  /// The constructor requires a CloudStories type
  const FolderStorageEvent(this.type,
      {this.parentID, this.folderID, this.error, this.data});

  /// used to tell the bloc which type of event this is
  final FolderStorageType type;

  /// generic data passed in the event
  final dynamic data;

  /// represents which folder this event is for, this can also be a sub event
  final String? folderID;

  /// usually set to the main folder folderID, used to find a sub folder
  final String? parentID;

  /// error message to pass on to the front end
  final String? error;
}
