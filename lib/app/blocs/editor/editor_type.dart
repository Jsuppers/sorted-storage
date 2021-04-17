/// possible types used for states and events
enum EditorType {
  updateMetadata,
  updateTimestamp,
  createStory,
  deleteStory,
  syncingState,
  /// delete a image
  deleteImage,
  ignoreImage,
  uploadImages,
  uploadStatus,
  updateImagePosition
}
