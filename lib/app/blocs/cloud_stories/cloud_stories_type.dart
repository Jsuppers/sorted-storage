/// possible types used for states and events
enum CloudStoriesType {
  /// initial state
  initialState,

  /// new user clears all information
  newUser,

  /// retrieve all stories from storage
  retrieveStories,

  /// retrieve a specific story from storage
  retrieveStory,

  /// create a single story
  createStory,

  /// update the progress of uploading
  progressUpload,

  /// update ui of current state of the local copy
  updateUI,

  /// syncing of a story has started
  syncingStart,

  /// syncing of a story has ended
  syncingEnd,

  /// update the state of syncing
  syncingState,

  /// delete a story
  deleteStory
}
