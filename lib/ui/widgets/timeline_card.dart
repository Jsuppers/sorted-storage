import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_type.dart';
import 'package:web/app/models/story_comment.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/pop_up_options.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

// ignore: public_member_api_docs
class TimelineCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineCard(
      {Key? key,
      required this.width,
      required this.folderId,
      required this.height,
      required this.event,
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
  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return const FullPageLoadingLogo(backgroundColor: Colors.white);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        key: Key(widget.event.subEvents!.length.toString()),
        child: Column(
          children: <Widget>[
            EventCard(
              storyFolderID: widget.event.mainStory.folderID,
              locked: true,
              controls: widget.viewMode
                  ? Container()
                  : PopUpOptions(
                      folderID: widget.folderId,
                      subFolderID: widget.event.mainStory.folderID),
              width: widget.width,
              height: widget.height,
              story: widget.event.mainStory,
            ),
            ...List<Widget>.generate(widget.event.subEvents!.length,
                (int index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: EventCard(
                    storyFolderID: widget.event.mainStory.folderID,
                    locked: true,
                    controls: Container(),
                    width: widget.width,
                    height: widget.height,
                    story: widget.event.subEvents![index]),
              );
            }),
            BlocBuilder<AuthenticationBloc, usr.User?>(
                builder: (BuildContext context, usr.User? user) {
              return CommentWidget(
                folderID: widget.folderId,
                user: user,
                width: widget.width,
                height: widget.height,
                sendComment: (BuildContext context, usr.User? currentUser,
                    String comment) async {
                  String user = 'Anonymous';
                  if (currentUser != null) {
                    user = currentUser.displayName;
                    if (user == null || user == '') {
                      user = currentUser.email;
                    }
                  }

                  BlocProvider.of<CommentHandlerBloc>(context).add(
                      CommentHandlerEvent(
                          CommentHandlerType.uploadingCommentsStart,
                          folderID: widget.folderId,
                          data: StoryComment(comment: comment, user: user)));
                },
              );
            })
          ],
        ),
      ),
    );
  }
}
