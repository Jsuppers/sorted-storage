// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/folder.dart';
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

  final Folder folder;

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    final List<_TimeLineEventEntry> timeLineEvents = <_TimeLineEventEntry>[];

    Folder.sortFolders(widget.folder.subFolders);
    for (final Folder subFolder in widget.folder.subFolders) {
      final Widget display = TimelineCard(
        width: widget.width,
        height: widget.height,
        folder: subFolder,
      );
      final _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(subFolder.metadata.getTimestamp(), display);
      timeLineEvents.add(_timeLineEventEntry);
    }

    for (final _TimeLineEventEntry element in timeLineEvents) {
      children.add(element.event);
    }
    if (children.isNotEmpty) {
      return Column(
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
