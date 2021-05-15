// Flutter imports:
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
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
  const TimelineLayout({Key? key,
    required this.width,
    required this.height,
    required this.folder,
  }): super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  final FolderContent folder;

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  late FolderContent folder;
  bool addingFolder = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folder = widget.folder;
//    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
//        CloudStoriesType.retrieveFolder,
//        folderID: folder.id));
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> children = <Widget>[];
    final List<_TimeLineEventEntry> timeLineEvents = <_TimeLineEventEntry>[];

    folder.subFolders ??= [];
    FolderContent.sortFolders(folder.subFolders);
    folder.subFolders!.forEach((FolderContent subFolder) {
      final Widget display = TimelineCard(
          width: widget.width,
          height: widget.height,
          folder: subFolder,
          parent: folder,
          folderId: subFolder.id!);
      final _TimeLineEventEntry _timeLineEventEntry =
      _TimeLineEventEntry(subFolder.getTimestamp(), display);
      timeLineEvents.add(_timeLineEventEntry);
    });

    for (final _TimeLineEventEntry element in timeLineEvents) {
      children.add(element.event);
    }
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
        listener: (BuildContext context, CloudStoriesState state) {
//          if (state.type == CloudStoriesType.retrieveFolder
//              && state.folderID == widget.folder.id) {
//            setState(() {
//              folder = state.data as FolderContent;
//            });
//          }
          if (state.type == CloudStoriesType.refresh) {
            if (state.error != null) {
              final SnackBar snackBar = SnackBar(
                content: Text(state.error!, textAlign: TextAlign.center),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }

            setState(() {
              addingFolder = false;
            });
          }
        },
        child: content(children));
  }

  Widget content(List<Widget> children) {
    if (children.isNotEmpty) {
      return Column(
        key: Key(DateTime.now().toString()),
        children: children,
      );
    }
    return Container(
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
