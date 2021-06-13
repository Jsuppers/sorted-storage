// Project imports:
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';

/// Event for the CloudStoriesBloc
class EditorEvent {
  /// The constructor requires a CloudStories type
  const EditorEvent(this.type,
      {this.parentID,
      this.folderID,
      this.error,
      this.data,
      this.closeDialog = false,
      this.refreshUI = false});

  /// represents which folder this event is for, this can also be a sub event
  final String? folderID;

  /// usually set to the main folder folderID, used to find a sub folder
  final String? parentID;

  /// used to tell the bloc which type of event this is
  final EditorType type;

  /// if we should close the dialog
  final bool closeDialog;

  final dynamic data;

  /// should refresh ui after save
  final bool refreshUI;

  /// error message to pass on to the front end
  final String? error;
}

class UpdateFilenameEvent {
  UpdateFilenameEvent({required this.filename, required this.folder});
  String filename;
  Folder folder;
}

class UpdateMetadataEvent {
  UpdateMetadataEvent({required this.metadata, required this.data});
  Map<String, dynamic> metadata;
  dynamic data;
}

class UpdateImagesEvent {
  UpdateImagesEvent({required this.images, required this.folder});
  Map<String, FileData> images;
  Folder folder;
}

class UpdateDeleteImageEvent {
  UpdateDeleteImageEvent({
    required this.imageID,
    required this.folder,
  });
  String imageID;
  Folder folder;
}
