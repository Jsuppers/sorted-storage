import 'package:web/app/models/story_content.dart';

/// contains the data for all stories
class StoryTimelineData {
  /// constructor which sets the default values
  StoryTimelineData(
      {this.mainStory,
      this.subEvents,
      this.locked = true,
      this.saving = false}) {
    subEvents ??= <StoryContent>[];
  }

  /// clone story data
  StoryTimelineData.clone(StoryTimelineData timelineEvent)
      : saving = timelineEvent.saving,
        locked = timelineEvent.locked,
        mainStory = StoryContent.clone(timelineEvent.mainStory),
        subEvents = List<StoryContent>.generate(timelineEvent.subEvents.length,
            (int index) => StoryContent.clone(timelineEvent.subEvents[index]));

  /// whether this story is saving
  bool saving;

  /// whether this story is currently locked
  bool locked;

  /// the content for the main story
  StoryContent mainStory;

  /// content for any sub stories
  List<StoryContent> subEvents;
}
