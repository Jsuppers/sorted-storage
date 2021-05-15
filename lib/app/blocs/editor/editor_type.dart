/// possible types used for states and events
enum EditorType {
  updateMetadata,
  updateName,
  updateTimestamp,
  createFolder,
  deleteStory,
  syncingState,

  /// delete a image
  deleteImage,
  ignoreImage,
  uploadImages,
  uploadStatus,
  updateImagePosition
}
