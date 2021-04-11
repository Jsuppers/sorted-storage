import 'package:web/app/models/story_content.dart';

enum SavingState {
  none,
  saving,
  success,
  error
}

/// contains the data for all stories
class StoryTimelineData {
  /// constructor which sets the default values
  StoryTimelineData(
      {this.mainStory,
      this.subEvents}) {
    subEvents ??= <StoryContent>[];
  }

  /// clone story data
  StoryTimelineData.clone(StoryTimelineData timelineEvent)
      : mainStory = StoryContent.clone(timelineEvent.mainStory),
        subEvents = List<StoryContent>.generate(timelineEvent.subEvents.length,
            (int index) => StoryContent.clone(timelineEvent.subEvents[index]));


  /// the content for the main story
  StoryContent mainStory;

  /// content for any sub stories
  List<StoryContent> subEvents;
}
