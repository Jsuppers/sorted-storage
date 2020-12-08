import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';

class TimelineEvent {
  final String folderId;
  final TimelineMessageType type;
  final AdventureComment comment;
  final String parentId;
  final int timestamp;
  final bool mainEvent;
  final DriveApi driveApi;
  final String imageKey;
  final String text;
  final dynamic data;
  final Map<String, List<String>> uploadingImages;

  const TimelineEvent(this.type,
      {this.data,
      this.uploadingImages,
      this.text,
      this.driveApi,
      this.parentId,
      this.imageKey,
      this.timestamp,
      this.mainEvent,
      this.folderId,
      this.comment});
}
