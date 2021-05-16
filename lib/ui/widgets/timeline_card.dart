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
import 'package:web/app/models/folder_content.dart';

// Project imports:
import 'package:web/ui/widgets/pop_up_options.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

// ignore: public_member_api_docs
class TimelineCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineCard(
      {Key? key,
      required this.width,
      required this.height,
      required this.folder,
      required this.parent,
      })
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final FolderContent folder;
  // ignore: public_member_api_docs
  final FolderContent parent;

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  FolderContent? folder;

  @override
  void initState() {
    super.initState();
    folder = widget.folder;
    if (folder?.loaded == null || folder!.loaded == false) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: widget.folder.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FolderContent> subFolders = folder?.subFolders ?? [];
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
        listener: (BuildContext context, CloudStoriesState state) {
          if (state.type == CloudStoriesType.refresh &&
              state.folderID == widget.parent.id) {
            setState(() {});
          }
        }, child: Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        key: Key(DateTime.now().toString()),
        child: Column(
          children: <Widget>[
            EventCard(
              controls: PopUpOptions(
                      folder: widget.folder,
                      parent: widget.parent,
              ),
              width: widget.width,
              height: widget.height,
              folder: folder!,
              parent: widget.parent,
            ),
          ],
        ),
      ),
    ),);
  }
}
