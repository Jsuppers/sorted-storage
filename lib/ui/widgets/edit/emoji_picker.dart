// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:emojis/emoji.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder.dart';

/// widget which allows a user to pick a emoji
class EmojiPicker extends StatefulWidget {
  // ignore: public_member_api_docs
  const EmojiPicker({Key? key, required this.folder}) : super(key: key);

  final Folder? folder;

  @override
  State createState() => EmojiPickerState();
}

/// state of the emoji widget
class EmojiPickerState extends State<EmojiPicker> {
  final TextEditingController _controller = TextEditingController();
  List<String> _possibleMatches = <String>[];
  late String _filter;
  final List<Emoji> _flags = Emoji.byGroup(EmojiGroup.flags).toList();

  @override
  void initState() {
    Emoji.byGroup(EmojiGroup.travelPlaces).forEach((Emoji element) {
      _possibleMatches.add(element.char!);
    });
    super.initState();

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        return;
      }

      _possibleMatches = <String>[];
      _filter = _controller.text;
      setState(() {
        for (final Emoji element in _flags) {
          if (element.name!.contains(_filter)) {
            _possibleMatches.add(element.char!);
          }
        }

        final Iterable<Emoji>? emojis = Emoji.byKeyword(_filter);
        if (emojis != null) {
          for (final Emoji element in emojis) {
            _possibleMatches.add(element.char!);
          }
        }
        final Emoji? emoji = Emoji.byName(_filter);
        if (emoji != null) {
          _possibleMatches.insert(0, emoji.char!);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: TextField(
                  style: const TextStyle(fontSize: 18.0, color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent()),
                    ),
                    hintText: 'Search...',
                  ),
                  controller: _controller,
                )),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildListView()),
              ),
            )
          ],
        ));
  }

  Widget _buildListView() {
    final List<Widget> children = <Widget>[];
    for (final String element in _possibleMatches) {
      children.add(
        MaterialButton(
          height: 40,
          onPressed: () {
            if (widget.folder != null) {
              final String fileName =
                  FolderNameData.toFileNameFromEmojiAndTitle(
                element,
                widget.folder!.title,
              );
              final UpdateFilenameEvent update = UpdateFilenameEvent(
                  filename: fileName, folder: widget.folder!);
              BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                  EditorType.updateName,
                  refreshUI: true,
                  data: update));
              BlocProvider.of<NavigationBloc>(context).add(NavigatorPopEvent());
            }
          },
          child: Text(
            element,
            style: const TextStyle(
              fontSize: 24,
              height: 1.1,
            ),
          ),
        ),
      );
    }

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
