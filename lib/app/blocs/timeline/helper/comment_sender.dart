import 'dart:convert';

import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentSender {
  GoogleDrive storage;
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;

  CommentSender(this.storage, this.cloudStories, this.localStories);

  Stream<TimelineState> processComment(TimelineCommentEvent event) async* {
    yield TimelineState(
        TimelineMessageType.uploading_comments_start, localStories,
        folderID: event.folderId);

    TimelineData timelineEvent = cloudStories[event.folderId];
    await _sendComment(timelineEvent.mainEvent, event.data);
    localStories[event.folderId].mainEvent.comments =
        timelineEvent.mainEvent.comments;

    yield TimelineState(
        TimelineMessageType.uploading_comments_finished, localStories,
        folderID: event.folderId,
        data: cloudStories[event.folderId].mainEvent.comments.comments);
  }

  Future _sendComment(EventContent event, AdventureComment comment) async {
    AdventureComments comments =
        AdventureComments.fromJson(await storage.getJsonFile(event.commentsID));
    if (comments == null) {
      comments = AdventureComments();
    }
    if (comments.comments == null) {
      comments.comments = [];
    }
    if (comment != null) {
      comments.comments.add(comment);
    }

    File eventToUpload = File();
    eventToUpload.parents = [event.folderID];
    eventToUpload.mimeType = "application/json";
    eventToUpload.name = Constants.COMMENTS_FILE;

    String jsonString = jsonEncode(comments);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    var folder;
    if (event.commentsID == null) {
      folder = await storage.createFile(
          eventToUpload, media: Media(mediaStream, fileContent.length));
      Permission anyone = Permission();
      anyone.type = "anyone";
      anyone.role = "writer";
      await storage.createPermission(folder.id, anyone);
    } else {
      folder = await storage.updateFile(
          null, event.commentsID, Media(mediaStream, fileContent.length));
    }

    event.comments = comments;
    event.commentsID = folder.id;
    return folder.id;
  }
}
