import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/ui/widgets/timeline.dart';

/// Page which contains all the stories
class MediaPage extends StatefulWidget {
  MediaPage(this.folderID);

  String folderID;

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveStories,
        folderID: widget.folderID));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return TimelineLayout(
              width: constraints.maxWidth, height: constraints.maxHeight);
        },
      ),
    );
  }
}
