// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/folder_content.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class _TimeLineEventEntry {
  final double? order;
  final Widget event;

  // ignore: sort_constructors_first
  _TimeLineEventEntry(this.order, this.event);
}

// ignore: public_member_api_docs
class TimelineLayout extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineLayout({
    Key? key,
    required this.width,
    required this.height,
    required this.folder,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  final FolderContent folder;

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    final List<_TimeLineEventEntry> timeLineEvents = <_TimeLineEventEntry>[];

    if (widget.folder.subFolders != null) {
      FolderContent.sortFolders(widget.folder.subFolders);
      widget.folder.subFolders!.forEach((FolderContent subFolder) {
        final Widget display = TimelineCard(
          width: widget.width,
          height: widget.height,
          folder: subFolder,
          parent: widget.folder,
        );
        final _TimeLineEventEntry _timeLineEventEntry =
            _TimeLineEventEntry(subFolder.getTimestamp(), display);
        timeLineEvents.add(_timeLineEventEntry);
      });
    }

    for (final _TimeLineEventEntry element in timeLineEvents) {
      children.add(element.event);
    }
    if (children.isNotEmpty) {
      return Column(
        key: Key(DateTime.now().toString()),
        children: children,
      );
    }
    return SizedBox(
      height: widget.height / 1.5,
      child: Center(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Image.asset(
                'assets/images/no_story.png',
                height: 150,
              ),
              const SizedBox(height: 10),
              const Text('It also looks pretty sad here!'),
              const SizedBox(height: 10),
              const Text("Click 'Add' and start your journey!"),
            ],
          ),
        ),
      ),
    );
  }
}
