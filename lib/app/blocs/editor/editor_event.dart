import 'package:web/app/blocs/editor/editor_type.dart';

/// Event for the CloudStoriesBloc
class EditorEvent {
  /// The constructor requires a CloudStories type
  const EditorEvent(this.type,
      {this.parentID,
      this.folderID,
      this.error,
      this.mainEvent,
      this.closeDialog,
      this.data,
      this.refreshUI = false});

  /// represents which story this event is for, this can also be a sub event
  final String folderID;

  /// usually set to the main story folderID, used to find a sub folder
  final String parentID;

  /// used to tell the bloc which type of event this is
  final EditorType type;

  /// if we should close the dialog
  final bool closeDialog;

  final dynamic data;

  /// should refresh ui after save
  final bool refreshUI;

  /// error message to pass on to the front end
  final String error;

  final bool mainEvent;
}
