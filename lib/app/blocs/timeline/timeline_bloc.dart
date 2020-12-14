import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:web/app/blocs/timeline/helper/cloud_changes.dart';
import 'package:web/app/blocs/timeline/helper/comment_sender.dart';
import 'package:web/app/blocs/timeline/helper/initial_changes.dart';
import 'package:web/app/blocs/timeline/helper/local_changes.dart';
import 'package:web/app/blocs/timeline/helper/ui_updater.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  Map<String, TimelineData> cloudStories;
  Map<String, TimelineData> localStories;
  String mediaFolderID;
  GoogleDrive storage;

  TimelineBloc()
      : super(TimelineState(TimelineMessageType.initial_state, Map()));

  @override
  Stream<TimelineState> mapEventToState(event) async* {
    if (event.type == TimelineMessageType.update_drive) {
      storage = GoogleDrive(event.data);
      return;
    }

    // events that initialize variables
    if (event is TimelineInitialEvent) {
      InitialChanges initialChanges = InitialChanges(
          storage, cloudStories, localStories);
      await for (TimelineState state in initialChanges.update(event,
              (timelineEvent) => this.add(timelineEvent),
              (folderID) => mediaFolderID = folderID,
              (cloudStoriesUpdate) => cloudStories = cloudStoriesUpdate,
              (localStoriesUpdate) => localStories = localStoriesUpdate)) {
        yield state;
      }
      return;
    }

    // sending and receiving comments
    if (event is TimelineCommentEvent) {
      CommentSender commentsHelper =
      CommentSender(storage, cloudStories, localStories);
      await for (TimelineState state in commentsHelper.processComment(event)) {
        yield state;
      }
      return;
    }

    // events which change the local copy of stories
    if (event is TimelineLocalEvent) {
      LocalChanges localState = LocalChanges(cloudStories, localStories);
      await for (TimelineState state in localState.changeLocalState(
          event, (timelineEvent) => this.add(timelineEvent))) {
        yield state;
      }
      return;
    }

    // events which updates the stories in google drive
    if (event is TimelineCloudEvent) {
      CloudChanges cloudState =
      CloudChanges(storage, cloudStories, localStories, mediaFolderID);
      await for (TimelineState state in cloudState.changeCloudState(
          event, (timelineEvent) => this.add(timelineEvent))) {
        yield state;
      }
      return;
    }

    // events which update the UI
    UIUpdater uiUpdater = UIUpdater(storage, cloudStories, localStories);
    await for (TimelineState state in uiUpdater.updateUI(event)) {
      yield state;
    }
  }
}
