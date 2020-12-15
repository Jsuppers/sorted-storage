import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

class EmojiPicker extends StatefulWidget {
  final String folderID;
  final String parentID;

  const EmojiPicker({Key key, this.folderID, this.parentID}) : super(key: key);

  @override
  State createState() => EmojiPickerState();
}

class EmojiPickerState extends State<EmojiPicker> {
  TextEditingController controller = new TextEditingController();
  List<String> possibleMatches = [];
  String filter;
  List<Emoji> flags;

  @override
  void initState() {
    flags = Emoji.byGroup(EmojiGroup.flags).toList();

    Emoji.byGroup(EmojiGroup.travelPlaces).forEach((element) {
      possibleMatches.add(element.char);
    });
    super.initState();

    controller.addListener(() {
      if (controller.text == "") {
        return;
      }

      possibleMatches = [];
      filter = controller.text;
      setState(() {
        flags.forEach((element) {
          if (element.name.contains(filter)) {
            possibleMatches.add(element.char);
          }
        });

        Iterable<Emoji> emojis = Emoji.byKeyword(filter);
        if (emojis != null) {
          emojis.forEach((element) {
            possibleMatches.add(element.char);
          });
        }
        Emoji emoji = Emoji.byName(filter);
        if (emoji != null) {
          possibleMatches.insert(0, emoji.char);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: new TextField(
                  style: new TextStyle(fontSize: 18.0, color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: new Icon(Icons.search),
                    suffixIcon: new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () => BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent()),
                    ),
                    hintText: "Search...",
                  ),
                  controller: controller,
                )),
            Expanded(
              child: SingleChildScrollView(
                child: new Padding(
                    padding: new EdgeInsets.only(top: 8.0),
                    child: _buildListView()),
              ),
            )
          ],
        ));
  }

  Widget _buildListView() {
    List<Widget> children = [];
    possibleMatches.forEach((element) {
      children.add(
        MaterialButton(
          height: 40,
          onPressed: () {
            BlocProvider.of<LocalStoriesBloc>(context).add(LocalStoriesEvent(
                LocalStoriesType.edit_emoji,
                parentId: widget.parentID,
                folderId: widget.folderID,
                data: element));
            BlocProvider.of<NavigationBloc>(context).add(NavigatorPopEvent());
          },
          child: Text(
            element,
            style: TextStyle(
              fontSize: 24,
              height: 1.1,
            ),
          ),
        ),
      );
    });

    return Align(
      alignment: Alignment.topCenter,
      child: Wrap(
        spacing: 15.0,
        runSpacing: 15.0,
        children: children,
      ),
    );
  }
}
