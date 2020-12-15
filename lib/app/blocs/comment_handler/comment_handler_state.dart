enum CommentHandlerType {
  uploading_comments_start,
  uploading_comments_finished,
}

class CommentHandlerState {
  final bool uploading;
  final String folderID;

  const CommentHandlerState({this.uploading, this.folderID});
}
