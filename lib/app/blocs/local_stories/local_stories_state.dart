import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class LocalStoriesState {
  const LocalStoriesState(this.type, this.localStories,
      {this.data, this.folderID});

  final LocalStoriesType type;
  final Map<String, TimelineData> localStories;
  final dynamic data;
  final String folderID;

}
