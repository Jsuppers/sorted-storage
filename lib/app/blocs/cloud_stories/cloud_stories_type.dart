/// possible types used for states and events
enum CloudStoriesType {
  /// new user clears all information
  newUser,

  /// retrieve a specific story from storage
  retrieveFolder,
  updateFolderPosition,
  rootFolder,

  /// update ui of current state of the local copy
  refresh,
}
