import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/models/story_comment.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// widget for comments
class CommentWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const CommentWidget(
      {Key key,
      this.sendComment,
      this.width,
      this.height,
      this.user,
      this.folderID})
      : super(key: key);

  final Function(BuildContext context, usr.User user, String comment)
      // ignore: public_member_api_docs
      sendComment;

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final usr.User user;

  // ignore: public_member_api_docs
  final String folderID;

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  List<StoryComment> adventureComments = <StoryComment>[];
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    adventureComments = BlocProvider.of<LocalStoriesBloc>(context)
        .state
        .localStories[widget.folderID]
        .mainStory
        .comments
        .comments;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final List<Widget> comments = <Widget>[];
    for (int i = 0; i < adventureComments.length; i++) {
      String user = adventureComments[i].user;
      if (user == null || user.isEmpty) {
        user = 'Anonymous';
      }
      comments.add(Row(
        children: <Widget>[
          Text(
            user,
            style: myThemeData.textTheme.headline4,
          ),
          const SizedBox(width: 10),
          Text(
            adventureComments[i].comment,
            style: myThemeData.textTheme.bodyText1,
          ),
        ],
      ));
    }
    return BlocListener<CommentHandlerBloc, CommentHandlerState>(
      listener: (BuildContext context, CommentHandlerState state) {
        if (state.folderID == widget.folderID) {
          setState(() {
            adventureComments = BlocProvider.of<LocalStoriesBloc>(context)
                .state
                .localStories[widget.folderID]
                .mainStory
                .comments
                .comments;
            uploading = state.uploading;
          });
        }
      },
      child: SizedBox(
        key: Key(adventureComments.length.toString()),
        width: widget.width,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: comments,
                ),
              ),
              if (widget.user == null)
                ButtonWithIcon(
                    text: 'Sign in to comment',
                    icon: Icons.login,
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationSignInEvent());
                    },
                    width: Constants.minScreenWidth,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black)
              else
                CommentSection(
                    controller: controller,
                    widget: widget,
                    uploading: uploading)
            ],
          ),
        ),
      ),
    );
  }
}

///
class CommentSection extends StatefulWidget {
  // ignore: public_member_api_docs
  const CommentSection({
    Key key,
    @required this.controller,
    @required this.widget,
    this.uploading,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final bool uploading;

  // ignore: public_member_api_docs
  final TextEditingController controller;

  // ignore: public_member_api_docs
  final CommentWidget widget;

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: myThemeData.primaryColorDark, width: 5.0),
                  ),
                  errorMaxLines: 0,
                  hintText: 'add a comment'),
              controller: widget.controller,
              style: myThemeData.textTheme.bodyText1,
              minLines: 1),
        ),
        if (widget.uploading)
          SizedBox(width: 120, child: StaticLoadingLogo())
        else
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: ButtonWithIcon(
                text: 'comment',
                icon: Icons.send,
                onPressed: () async {
                  if (widget.controller.text.isEmpty) {
                    return;
                  }
                  await widget.widget.sendComment(
                      context, widget.widget.user, widget.controller.text);
                  widget.controller.text = '';
                },
                width: Constants.minScreenWidth,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                iconColor: Colors.black),
          )
      ],
    );
  }
}
