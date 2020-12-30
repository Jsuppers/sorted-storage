import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_type.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/story_comment.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

// ignore: public_member_api_docs
class TimelineCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineCard(
      {Key key,
      @required this.width,
      this.height,
      @required this.event,
      this.folderId,
      this.viewMode = false})
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final StoryTimelineData event;

  // ignore: public_member_api_docs
  final String folderId;

  // ignore: public_member_api_docs
  final bool viewMode;

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  StoryTimelineData adventure;
  bool locked;
  bool saving;

  Widget createHeader(double width, BuildContext context) {
    if (saving) {
      return SavingIcon(folderID: adventure.mainStory.folderID);
    }
    return Container(
      height: 30,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      child: locked
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ButtonWithIcon(
                    text: 'share',
                    icon: Icons.share,
                    onPressed: () {
                      DialogService.shareDialog(
                          context,
                          adventure.mainStory.folderID,
                          adventure.mainStory.commentsID);
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                const SizedBox(width: 10),
                ButtonWithIcon(
                    text: 'edit',
                    icon: Icons.edit,
                    onPressed: () {
                      BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.editStory,
                              folderID: widget.folderId));
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ButtonWithIcon(
                    text: 'cancel',
                    icon: Icons.cancel,
                    onPressed: () {
                      BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.cancelStory,
                              folderID: widget.folderId,
                              data: BlocProvider.of<CloudStoriesBloc>(context)
                                  .cloudStories));
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                const SizedBox(width: 10),
                ButtonWithIcon(
                    text: 'delete',
                    icon: Icons.delete,
                    onPressed: () {
                      BlocProvider.of<CloudStoriesBloc>(context).add(
                          CloudStoriesEvent(CloudStoriesType.deleteStory,
                              folderID: widget.folderId));
                    },
                    width: width,
                    backgroundColor: Colors.redAccent),
                const SizedBox(width: 10),
                ButtonWithIcon(
                    text: 'save',
                    icon: Icons.save,
                    onPressed: () async {
                      BlocProvider.of<CloudStoriesBloc>(context).add(
                          CloudStoriesEvent(CloudStoriesType.syncingStart,
                              folderID: widget.folderId));
                    },
                    width: width,
                    backgroundColor: Colors.greenAccent),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    adventure = widget.event;
    if (adventure == null) {
      locked = true;
      saving = false;
    } else {
      locked = adventure.locked;
      saving = adventure.saving;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (adventure == null) {
      return const FullPageLoadingLogo(backgroundColor: Colors.white);
    }
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (BuildContext context, CloudStoriesState state) {
            if (state.type == CloudStoriesType.syncingStart &&
                state.folderID == widget.folderId) {
              setState(() {
                saving = BlocProvider.of<LocalStoriesBloc>(context)
                    .state
                    .localStories[state.folderID]
                    .saving;
              });
            }
            if (state.type == CloudStoriesType.syncingEnd &&
                state.folderID == widget.folderId) {
              final List<String> errorMessages = state.data as List<String>;
              if (errorMessages != null && errorMessages.isNotEmpty) {
                DialogService.errorSyncingDialog(context,
                    errorMessages: errorMessages);
              }

              setState(() {
                adventure = BlocProvider.of<LocalStoriesBloc>(context)
                    .state
                    .localStories[state.folderID];
                adventure.subEvents.sort((StoryContent a, StoryContent b) =>
                    b.timestamp.compareTo(a.timestamp));
                locked = adventure.locked;
                saving = adventure.saving;
              });
            }
          },
        ),
        BlocListener<LocalStoriesBloc, LocalStoriesState>(
          listener: (BuildContext context, LocalStoriesState state) {
            if (state.type == LocalStoriesType.editStory &&
                state.folderID == widget.folderId) {
              setState(() {
                locked = state.localStories[state.folderID].locked;
              });
            } else if ((state.type == LocalStoriesType.cancelStory ||
                    state.type == LocalStoriesType.updateUI) &&
                state.folderID == widget.folderId) {
              setState(() {
                adventure = state.localStories[state.folderID];
                adventure.subEvents.sort((StoryContent a, StoryContent b) =>
                    b.timestamp.compareTo(a.timestamp));
                locked = adventure.locked;
                saving = adventure.saving;
              });
            } else if (state.type == LocalStoriesType.updateUI) {
              final StoryContent subEvent = adventure.subEvents.firstWhere(
                  (StoryContent element) => element.folderID == state.folderID,
                  orElse: () {
                return;
              });
              if (subEvent == null) {
                return;
              }
              setState(() {});
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          key: Key(adventure.subEvents.length.toString()),
          child: Column(
            children: [
              EventCard(
                storyFolderID: adventure.mainStory.folderID,
                saving: saving,
                locked: locked,
                controls: widget.viewMode
                    ? Container()
                    : createHeader(widget.width, context),
                width: widget.width,
                height: widget.height,
                story: adventure.mainStory,
              ),
              Visibility(
                visible: !locked,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: 40,
                    width: 140,
                    child: ButtonWithIcon(
                        text: 'add sub-event',
                        icon: Icons.add,
                        onPressed: () async {
                          if (saving) {
                            return;
                          }
                          BlocProvider.of<LocalStoriesBloc>(context).add(
                              LocalStoriesEvent(LocalStoriesType.createSubStory,
                                  parentID: adventure.mainStory.folderID,
                                  folderID: widget.folderId));
                        },
                        width: Constants.minScreenWidth,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  ),
                ),
              ),
              ...List<Widget>.generate(adventure.subEvents.length, (int index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                      child: EventCard(
                          storyFolderID: adventure.mainStory.folderID,
                          saving: saving,
                          locked: locked,
                          controls: Visibility(
                            visible: !locked,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 3, top: 3),
                                child: Container(
                                  height: 34,
                                  width: 34,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(40))),
                                  child: IconButton(
                                    iconSize: 18,
                                    splashRadius: 18,
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      if (saving) {
                                        return;
                                      }
                                      BlocProvider.of<LocalStoriesBloc>(context)
                                          .add(LocalStoriesEvent(
                                              LocalStoriesType.deleteSubStory,
                                              parentID:
                                                  adventure.mainStory.folderID,
                                              folderID: adventure
                                                  .subEvents[index].folderID));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          width: widget.width,
                          height: widget.height,
                          story: adventure.subEvents[index])),
                );
              }),
              BlocBuilder<AuthenticationBloc, usr.User>(
                  builder: (BuildContext context, usr.User user) {
                return CommentWidget(
                  folderID: widget.folderId,
                  user: user,
                  width: widget.width,
                  height: widget.height,
                  sendComment: (BuildContext context, usr.User currentUser,
                      String comment) async {
                    String user = '';
                    if (currentUser != null) {
                      user = currentUser.displayName;
                      if (user == null || user == '') {
                        user = currentUser.email;
                      }
                    }

                    final StoryComment eventComment =
                        StoryComment(comment: comment, user: user);

                    BlocProvider.of<CommentHandlerBloc>(context).add(
                        CommentHandlerEvent(
                            CommentHandlerType.uploadingCommentsStart,
                            folderID: widget.folderId,
                            data: eventComment));
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: public_member_api_docs
class SavingIcon extends StatefulWidget {
  // ignore: public_member_api_docs
  const SavingIcon({
    Key key,
    this.folderID,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String folderID;

  @override
  _SavingIconState createState() => _SavingIconState();
}

class _SavingIconState extends State<SavingIcon> {
  double percent = 0;
  String text = '0%';

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.progressUpload &&
            state.folderID == widget.folderID) {
          final MediaProgress progress = state.data as MediaProgress;
          setState(() {
            // TODO this shows file loading progress not sending progress
            final int total =
                progress.total + 1; // we will be evil and never show 100%
            final int sent = progress.sent;
            if (sent == 0) {
              percent = 0;
            } else {
              percent = sent / total;
            }
            text = '${(percent * 100).toInt()}%';
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircularPercentIndicator(
            radius: 48.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text(
              text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: myThemeData.accentColor,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
