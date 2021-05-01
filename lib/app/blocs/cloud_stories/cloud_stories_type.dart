/// possible types used for states and events
enum CloudStoriesType {
  /// initial state
  initialState,

  /// new user clears all information
  newUser,

  /// retrieve all stories from storage
  retrieveStories,

  /// retrieve a specific story from storage
  retrieveFolders,

  createFolder,
  deleteFolder,
  updateFolderPosition,

  rootFolder,

  /// retrieve a specific story from storage
  retrieveStory,

  editStory,

  /// update ui of current state of the local copy
  refresh,
}
