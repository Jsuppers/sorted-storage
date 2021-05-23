/// possible types used for states and events
enum FolderStorageType {
  /// new user clears all information
  newUser,

  /// retrieve a specific story from storage
  getFolder,

  /// get the root folder for the user
  getRootFolder,

  /// update ui of current state of the local copy
  refresh,
}
