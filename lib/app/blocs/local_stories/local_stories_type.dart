/// possible types used for states and events
enum LocalStoriesType {
  /// initial state
  initialState,

  /// one or images have been added
  pickedImage,

  /// create a sub story
  createSubStory,

  /// delete a sub story
  deleteSubStory,

  /// edit the timestamp
  editTimestamp,

  /// edit the description
  editDescription,

  /// edit the emoji
  editEmoji,

  /// edit the title
  editTitle,

  /// event to start adding images
  addImage,

  /// cancel story resetting all unsaved changes
  cancelStory,

  /// allow user to start editing local story
  editStory,

  /// update ui of current state of the local copy
  updateUI,
}
