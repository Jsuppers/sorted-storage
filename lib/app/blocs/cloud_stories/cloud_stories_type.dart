/// possible types used for states and events
enum CloudStoriesType {
  /// initial state
  initialState,

  /// new user clears all information
  newUser,

  /// retrieve a specific story from storage
  retrieveFolder,

  createFolder,
  deleteFolder,
  updateFolderPosition,

  rootFolder,

  editStory,

  /// update ui of current state of the local copy
  refresh,
}
