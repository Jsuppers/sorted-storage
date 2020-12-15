import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentHandlerBloc extends Bloc<CommentHandlerEvent, CommentHandlerState>{
  GoogleDrive storage;
  Map<String, TimelineData> localStories;

  CommentHandlerBloc({this.localStories, this.storage}) : super(CommentHandlerState(uploading: false));

  @override
  Stream<CommentHandlerState> mapEventToState(event) async* {
    yield CommentHandlerState(
        uploading: true,
        folderID: event.folderId);

    TimelineData timelineEvent = localStories[event.folderId];
    await _sendComment(timelineEvent.mainEvent, event.data);

    yield CommentHandlerState(
        uploading: false,
        folderID: event.folderId);
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
