/// possible types used for states and events
enum EditorType {
  updateMetadata,
  updateName,
  updateTimestamp,
  createFolder,
  deleteFolder,
  syncingState,

  /// delete a image
  deleteImage,
  ignoreImage,
  uploadImages,
  uploadStatus,
  updateImagePosition
}
