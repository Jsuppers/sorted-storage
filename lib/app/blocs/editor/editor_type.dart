/// possible types used for states and events
enum EditorType {
  updateMetadata,
  updateName,
  createFolder,
  deleteFolder,
  syncingState,

  /// delete a image
  deleteImage,
  ignoreImage,
  uploadImages,
  uploadStatus,
  updatePosition
}
