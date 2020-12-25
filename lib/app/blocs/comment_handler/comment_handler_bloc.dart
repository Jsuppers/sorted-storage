import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/comments_response.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// handles uploading comments
class CommentHandlerBloc
    extends Bloc<CommentHandlerEvent, CommentHandlerState> {
  /// sets the current state to not uploading
  CommentHandlerBloc(
      {Map<String, TimelineData> localStories, GoogleDrive storage})
      : super(const CommentHandlerState(uploading: false)) {
    _localStories = localStories;
    _storage = storage;
  }

  GoogleDrive _storage;
  Map<String, TimelineData> _localStories;

  @override
  Stream<CommentHandlerState> mapEventToState(
      CommentHandlerEvent event) async* {
    yield CommentHandlerState(uploading: true, folderID: event.folderID);

    final TimelineData timelineEvent = _localStories[event.folderID];
    final CommentsResponse commentsResponse = await _storage.uploadCommentsFile(
        commentsID: timelineEvent.mainStory.commentsID,
        folderID: event.folderID,
        comment: event.data as AdventureComment);

    timelineEvent.mainStory.comments = commentsResponse.comments;
    timelineEvent.mainStory.commentsID = commentsResponse.commentsID;

    yield CommentHandlerState(uploading: false, folderID: event.folderID);
  }
}
