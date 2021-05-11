// Flutter imports:
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/story_content.dart';

// Project imports:
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
      required this.folder,
        required this.parent,
      this.viewMode = false})
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final FolderContent folder;
  // ignore: public_member_api_docs
  final FolderContent parent;

  // ignore: public_member_api_docs
  final String folderId;

  // ignore: public_member_api_docs
  final bool viewMode;

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  FolderContent? folder;

  @override
  void initState() {
    super.initState();
    folder = widget.folder;
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveFolder,
        folderID: widget.folderId));
  }

  @override
  Widget build(BuildContext context) {
    List<FolderContent> subFolders = folder?.subFolders ?? [];

    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
        listener: (BuildContext context, CloudStoriesState state) {
          if (state.type == CloudStoriesType.retrieveFolder
              && state.folderID == widget.folderId) {
            setState(() {
              folder = state.data as FolderContent;
            });
          }

        }, child: Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        key: Key(DateTime.now().toString()),
        child: Column(
          children: <Widget>[
            EventCard(
              locked: true,
              controls: widget.viewMode
                  ? Container()
                  : PopUpOptions(
                      folderID: widget.folderId,
                      parent: widget.parent,
                      subFolderID:  widget.folderId,),
              width: widget.width,
              height: widget.height,
              folder: folder!,
            ),
            ...List<Widget>.generate(subFolders.length,
                (int index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: EventCard(
                    locked: true,
                    controls: Container(),
                    width: widget.width,
                    height: widget.height,
                    folder: subFolders[index]),
              );
            }),
          ],
        ),
      ),
    ),);
  }
}
