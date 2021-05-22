// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/ui/widgets/pop_up_options.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

// ignore: public_member_api_docs
class TimelineCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineCard({
    Key? key,
    required this.width,
    required this.height,
    required this.folder,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final FolderContent folder;

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  FolderContent? folder;
  late String key;

  @override
  void initState() {
    super.initState();
    key = DateTime.now().toString();
    folder = widget.folder;
    if (folder?.loaded == null || folder!.loaded == false) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: widget.folder.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState?>(
      listener: (BuildContext context, CloudStoriesState? state) {
        if (state == null) {
          return;
        }
        if (state.type == CloudStoriesType.refresh &&
            state.folderID == folder?.parent?.id &&
            state.data != null) {
          FolderContent? refreshFolder = state.data as FolderContent?;
          debugger();
          if (refreshFolder != null && refreshFolder.id == folder!.id) {
            setState(() {
              key = DateTime.now().toString();
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          child: Column(
            children: <Widget>[
              EventCard(
                key: Key(key),
                controls: folder?.amOwner != null && folder!.amOwner == true
                    ? PopUpOptions(
                        folder: widget.folder,
                      )
                    : Container(),
                width: widget.width,
                height: widget.height,
                folder: folder!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
