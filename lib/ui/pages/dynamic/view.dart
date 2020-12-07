import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class ViewPage extends StatefulWidget {
  static const String route = '/view';
  final String path;

  const ViewPage({Key key, this.path}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String eventFolderID;
  TimelineData timelineData;

  @override
  void initState() {
    super.initState();
    int pathLength = widget.path.length;
    int pathPrefix = ViewPage.route.length;

    eventFolderID = pathLength < pathPrefix + 1
        ? null
        : widget.path.substring(pathPrefix + 1);
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state.type == TimelineMessageType.updated_stories) {
          setState(() {
            timelineData = state.stories[eventFolderID];
            timelineData.subEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          });
        }
      },
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: TimelineCard(
              key: Key(timelineData.toString()),
                viewMode: true,
                width: sizingInformation.screenSize.width,
                event: timelineData,
                folderId: eventFolderID),
          );
        },
      ),
    );
  }
}
