/// possible types used for states and events
enum CloudStoriesType {
  /// new user clears all information
  newUser,

  /// retrieve a specific story from storage
  retrieveFolder,

  /// update the folder's position
  updateFolderPosition,

  /// get the root folder for the user
  getRootFolder,

  /// update ui of current state of the local copy
  refresh,
}
