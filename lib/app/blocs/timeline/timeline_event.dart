import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';

class TimelineEvent {
  final String folderId;
  final TimelineMessageType type;
  final String parentId;
  final bool mainEvent;
  final dynamic data;

  const TimelineEvent(this.type,
      {this.data, this.parentId, this.mainEvent, this.folderId});
}

class TimelineLocalEvent extends TimelineEvent {
  TimelineLocalEvent(TimelineMessageType type,
      {dynamic data, String parentId, String folderId, bool mainEvent})
      : super(type,
            data: data,
            parentId: parentId,
            folderId: folderId,
            mainEvent: mainEvent);
}

class TimelineCommentEvent extends TimelineEvent {
  final TimelineMessageType type;
  final String folderId;
  final AdventureComment comment;

  TimelineCommentEvent(this.type, this.folderId, this.comment)
      : super(type, data: comment, folderId: folderId);
}

class TimelineInitialEvent extends TimelineEvent {
  TimelineInitialEvent(TimelineMessageType type, {String folderId})
      : super(type, folderId: folderId);
}

class TimelineRetrieveStoriesEvent extends TimelineEvent {
  TimelineRetrieveStoriesEvent(TimelineMessageType type) : super(type);
}

class TimelineCloudEvent extends TimelineEvent {
  TimelineCloudEvent(TimelineMessageType type,
      {dynamic data, String parentId, String folderId, bool mainEvent})
      : super(type,
            data: data,
            parentId: parentId,
            folderId: folderId,
            mainEvent: mainEvent);
}
