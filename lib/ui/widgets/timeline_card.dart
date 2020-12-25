import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_type.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

class TimelineData {
  TimelineData(
      {this.mainStory,
      this.subEvents,
      this.locked = true,
      this.saving = false});

  bool saving;
  bool locked;
  StoryContent mainStory;
  List<StoryContent> subEvents;

  static TimelineData clone(TimelineData timelineEvent) {
    return TimelineData(
        saving: timelineEvent.saving,
        locked: timelineEvent.locked,
        mainStory: StoryContent.clone(timelineEvent.mainStory),
        subEvents: List.generate(timelineEvent.subEvents.length,
            (index) => StoryContent.clone(timelineEvent.subEvents[index])));
  }
}

class StoryMedia {
  StoryMedia({
    this.imageURL,
    this.stream,
    this.isVideo = false,
    this.isDocument = false,
    this.size,
  });

  String imageURL;
  bool isVideo;
  bool isDocument;
  int size;
  Stream<List<int>> stream;
}

class SubEvent {
  SubEvent(this.id, this.timestamp);

  final String id;
  final int timestamp;
}

class StoryContent {
  StoryContent(
      {this.timestamp,
      this.title = '',
      this.emoji = '',
      this.images,
      this.description = '',
      this.folderID,
      this.settingsID,
      this.subEvents,
      this.commentsID,
      this.comments}) {
    this.images ??= Map<String, StoryMedia>();
    this.subEvents ??= <SubEvent>[];
  }

  int timestamp;
  String emoji;
  String title;
  Map<String, StoryMedia> images;
  String description;
  String folderID;
  String settingsID;
  String commentsID;
  String permissionID;
  AdventureComments comments;
  List<SubEvent> subEvents;

  StoryContent.clone(StoryContent event)
      : this(
            timestamp: event.timestamp,
            title: event.title,
            emoji: event.emoji,
            images: Map.from(event.images),
            description: event.description,
            settingsID: event.settingsID,
            commentsID: event.commentsID,
            folderID: event.folderID,
            subEvents: List.from(event.subEvents),
            comments: AdventureComments.clone(event.comments));
}

class TimelineCard extends StatefulWidget {
  final double width;
  final double height;
  final TimelineData event;
  final String folderId;
  final bool viewMode;

  const TimelineCard(
      {Key key,
      @required this.width,
      this.height,
      @required this.event,
      this.folderId,
      this.viewMode = false})
      : super(key: key);

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  TimelineData adventure;
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
              children: [
                ButtonWithIcon(
                    text: "share",
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
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "edit",
                    icon: Icons.edit,
                    onPressed: () {
                      BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.edit_story,
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
              children: [
                ButtonWithIcon(
                    text: "cancel",
                    icon: Icons.cancel,
                    onPressed: () {
                      BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.cancel_story,
                              folderID: widget.folderId,
                              data: BlocProvider.of<CloudStoriesBloc>(context)
                                  .cloudStories));
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "delete",
                    icon: Icons.delete,
                    onPressed: () {
                      BlocProvider.of<CloudStoriesBloc>(context).add(
                          CloudStoriesEvent(CloudStoriesType.delete_story,
                              folderId: widget.folderId));
                    },
                    width: width,
                    backgroundColor: Colors.redAccent),
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "save",
                    icon: Icons.save,
                    onPressed: () async {
                      BlocProvider.of<CloudStoriesBloc>(context).add(
                          CloudStoriesEvent(
                              CloudStoriesType.syncing_story_start,
                              folderId: widget.folderId));
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
    locked = adventure == null ? true : adventure.locked;
    saving = adventure == null ? false : adventure.saving;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewMode) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieve_story,
          folderId: widget.folderId));
    }
    if (adventure == null) {
      return FullPageLoadingLogo(backgroundColor: Colors.white);
    }
    return MultiBlocListener(
      listeners: [
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (context, state) {
            if (state.type == CloudStoriesType.syncing_story_start &&
                state.folderID == widget.folderId) {
              setState(() {
                saving = BlocProvider.of<LocalStoriesBloc>(context)
                    .state
                    .localStories[state.folderID]
                    .saving;
              });
            }
            if (state.type == CloudStoriesType.syncing_story_end &&
                state.folderID == widget.folderId) {
              setState(() {
                adventure = BlocProvider.of<LocalStoriesBloc>(context)
                    .state
                    .localStories[state.folderID];
                adventure.subEvents
                    .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                locked = adventure.locked;
                saving = adventure.saving;
              });
            }
          },
        ),
        BlocListener<LocalStoriesBloc, LocalStoriesState>(
          listener: (context, state) {
            print(
                'type: ${state.type} folderID: ${state.folderID} currentID: ${widget.folderId}');
            if (state.type == LocalStoriesType.edit_story &&
                state.folderID == widget.folderId) {
              setState(() {
                locked = state.localStories[state.folderID].locked;
              });
            } else if ((state.type == LocalStoriesType.cancel_story ||
                    state.type == LocalStoriesType.syncing_story_end) &&
                state.folderID == widget.folderId) {
              setState(() {
                adventure = state.localStories[state.folderID];
                adventure.subEvents
                    .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                locked = adventure.locked;
                saving = adventure.saving;
              });
            } else if (state.type == LocalStoriesType.syncing_story_end) {
              var subEvent = adventure.subEvents.firstWhere(
                  (element) => element.folderID == state.folderID, orElse: () {
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
                eventFolderID: adventure.mainStory.folderID,
                saving: saving,
                locked: locked,
                controls: widget.viewMode
                    ? Container()
                    : createHeader(widget.width, context),
                width: widget.width,
                height: widget.height,
                event: adventure.mainStory,
              ),
              Visibility(
                visible: !locked,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: 40,
                    width: 140,
                    child: ButtonWithIcon(
                        text: "add sub-event",
                        icon: Icons.add,
                        onPressed: () async {
                          if (saving) {
                            return;
                          }
                          BlocProvider.of<LocalStoriesBloc>(context).add(
                              LocalStoriesEvent(
                                  LocalStoriesType.create_sub_story,
                                  parentID: adventure.mainStory.folderID,
                                  folderID: widget.folderId));
                        },
                        width: Constants.SMALL_WIDTH,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  ),
                ),
              ),
              ...List.generate(adventure.subEvents.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                      child: EventCard(
                          eventFolderID: adventure.mainStory.folderID,
                          saving: saving,
                          locked: locked,
                          controls: Visibility(
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(right: 3, top: 3),
                                    child: Container(
                                      height: 34,
                                      width: 34,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                      child: IconButton(
                                        iconSize: 18,
                                        splashRadius: 18,
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          if (saving) {
                                            return;
                                          }
                                          BlocProvider.of<LocalStoriesBloc>(
                                                  context)
                                              .add(
                                                  LocalStoriesEvent(
                                                      LocalStoriesType
                                                          .delete_sub_story,
                                                      parentID: adventure
                                                          .mainStory.folderID,
                                                      folderID: adventure
                                                          .subEvents[index]
                                                          .folderID));
                                        },
                                      ),
                                    ),
                                  )),
                              visible: !locked),
                          width: widget.width,
                          height: widget.height,
                          event: adventure.subEvents[index])),
                );
              }),
              BlocBuilder<AuthenticationBloc, usr.User>(
                  builder: (context, user) {
                return CommentWidget(
                  folderID: widget.folderId,
                  user: user,
                  width: widget.width,
                  height: widget.height,
                  sendComment: (BuildContext context, usr.User currentUser,
                      String comment) async {
                    String user = "";
                    if (currentUser != null) {
                      user = currentUser.displayName;
                      if (user == null || user == "") {
                        user = currentUser.email;
                      }
                    }

                    AdventureComment eventComment =
                        AdventureComment(comment: comment, user: user);

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

class SavingIcon extends StatefulWidget {
  final String folderID;

  const SavingIcon({
    Key key,
    this.folderID,
  }) : super(key: key);

  @override
  _SavingIconState createState() => _SavingIconState();
}

class _SavingIconState extends State<SavingIcon> {
  double percent = 0;
  String text = "0%";

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (context, state) {
        if (state.type == CloudStoriesType.progress_upload &&
            state.folderID == widget.folderID) {
          MediaProgress progress = state.data as MediaProgress;
          setState(() {
            // TODO this shows file loading progress not sending progress
            var total =
                progress.total + 1; // we will be evil and never show 100%
            var sent = progress.sent;
            if (sent == 0) {
              percent = 0;
            } else {
              percent = sent / total;
            }
            text = (percent * 100).toInt().toString() + "%";
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
            center: new Text(
              text,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
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

class TimelineHeader extends StatefulWidget {
  @override
  _TimelineHeaderState createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends State<TimelineHeader> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ButtonWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final double width;

  const ButtonWithIcon(
      {Key key,
      this.text,
      this.icon,
      this.onPressed,
      this.iconColor = Colors.white,
      this.backgroundColor,
      this.textColor = Colors.white,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buttonWithIcon(this.text, this.icon, this.onPressed, this.iconColor,
        this.backgroundColor, this.textColor, this.width);
  }

  Widget buttonWithIcon(String text, IconData icon, Function onPressed,
      Color iconColor, Color backgroundColor, Color textColor, double width) {
    return MaterialButton(
        minWidth: width >= Constants.SMALL_WIDTH ? 100 : 30,
        child: width >= Constants.SMALL_WIDTH
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Icon(
                icon,
                color: iconColor,
              ),
        color: backgroundColor,
        textColor: textColor,
        onPressed: () => onPressed());
  }
}
