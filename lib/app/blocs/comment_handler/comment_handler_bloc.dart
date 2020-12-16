import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentHandlerBloc
    extends Bloc<CommentHandlerEvent, CommentHandlerState> {
  GoogleDrive storage;
  Map<String, TimelineData> localStories;

  CommentHandlerBloc({this.localStories, this.storage})
      : super(CommentHandlerState(uploading: false));

  @override
  Stream<CommentHandlerState> mapEventToState(event) async* {
    yield CommentHandlerState(uploading: true, folderID: event.folderId);

    TimelineData timelineEvent = localStories[event.folderId];
    var commentsResponse = await storage.uploadCommentsFile(
        commentsID: timelineEvent.mainEvent.commentsID,
        folderID: event.folderId,
        comment: event.data);
    timelineEvent.mainEvent.comments = commentsResponse.comments;
    timelineEvent.mainEvent.commentsID = commentsResponse.commentsID;

    yield CommentHandlerState(uploading: false, folderID: event.folderId);
  }
}