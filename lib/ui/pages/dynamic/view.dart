// Flutter imports:
import 'dart:developer';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// page which shows a single story
class ViewPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ViewPage(this._destination, {Key? key}) : super(key: key);

  final String _destination;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  FolderContent? folder;
  bool error = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveFolder,
        folderID: widget._destination));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.refresh) {
          if (state.error != null) {
            setState(() => error = true);
          } else if (state.data != null) {
            setState(() {
              folder = state.data as FolderContent;
              folder!.subFolders!.sort((FolderContent a, FolderContent b) =>
                  b.order!.compareTo(a.order!));
            });
          }
        }
      },
      child: ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation info) {
          return error
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text(
                      'Error getting content',
                      style: myThemeData.textTheme.headline3,
                    ),
                    Text(
                      'are you sure the link is correct?',
                      style: myThemeData.textTheme.bodyText1,
                    ),
                    Image.asset('assets/images/error.png'),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TimelineCard(
                      key: Key(folder.toString()),
                      viewMode: true,
                      width: info.screenSize.width,
                      height: info.screenSize.height,
                      folder: folder!,
                      parent: folder!,
                      folderId: widget._destination),
                );
        },
      ),
    );
  }
}
