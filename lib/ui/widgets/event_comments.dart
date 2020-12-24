import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentWidget extends StatefulWidget {
  final Function(BuildContext context, usr.User user, String comment)
      sendComment;
  final double width;
  final double height;
  final usr.User user;
  final String folderID;

  const CommentWidget(
      {Key key,
      this.sendComment,
      this.width,
      this.height,
      this.user,
      this.folderID})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  List<AdventureComment> adventureComments = [];
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
    TextEditingController controller = TextEditingController();
    List<Widget> comments = [];
    for (int i = 0; i < adventureComments.length; i++) {
      String user = adventureComments[i].user;
      if (user == null || user == "") {
        user = "Anonymous";
      }
      comments.add(Container(
        child: Row(
          children: [
            Text(
              '$user',
              style: myThemeData.textTheme.headline4,
            ),
            SizedBox(width: 10),
            Text(
              '${adventureComments[i].comment}',
              style: myThemeData.textTheme.bodyText1,
            ),
          ],
        ),
      ));
    }
    return BlocListener<CommentHandlerBloc, CommentHandlerState>(
      listener: (context, state) {
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
      child: Container(
        key: Key(adventureComments.length.toString()),
        width: widget.width,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: comments,
                ),
              ),
              widget.user == null
                  ? ButtonWithIcon(
                      text: "Sign in to comment",
                      icon: Icons.login,
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(AuthenticationSignInEvent());
                      },
                      width: Constants.SMALL_WIDTH,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      iconColor: Colors.black)
                  : CommentSection(
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

class CommentSection extends StatefulWidget {
  final bool uploading;

  const CommentSection({
    Key key,
    @required this.controller,
    @required this.widget,
    this.uploading,
  }) : super(key: key);

  final TextEditingController controller;
  final CommentWidget widget;

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
              decoration: new InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: myThemeData.primaryColorDark, width: 5.0),
                  ),
                  errorMaxLines: 0,
                  hintText: 'add a comment'),
              controller: widget.controller,
              style: myThemeData.textTheme.bodyText1,
              minLines: 1,
              readOnly: false),
        ),
        widget.uploading
            ? Container(width: 120, child: StaticLoadingLogo())
            : Container(
                padding: EdgeInsets.only(left: 20),
                child: ButtonWithIcon(
                    text: "comment",
                    icon: Icons.send,
                    onPressed: () async {
                      if (widget.controller.text.length == 0) {
                        return;
                      }
                      await widget.widget.sendComment(
                          context, widget.widget.user, widget.controller.text);
                      widget.controller.text = "";
                    },
                    width: Constants.SMALL_WIDTH,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
              )
      ],
    );
  }
}
