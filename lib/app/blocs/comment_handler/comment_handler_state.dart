/// response state of the comment bloc
class CommentHandlerState {
  /// constructor
  const CommentHandlerState({this.error, this.uploading, this.folderID});

  /// holds the current state of uploading comments
  final bool? uploading;

  /// holds the folder ID where the comments are related to
  final String? folderID;

  /// error message to send
  final String? error;
}
