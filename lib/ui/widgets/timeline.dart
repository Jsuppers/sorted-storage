import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class _TimeLineEventEntry {
  final int timestamp;
  final Widget event;

  // ignore: sort_constructors_first
  _TimeLineEventEntry(this.timestamp, this.event);
}

// ignore: public_member_api_docs
class TimelineLayout extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimelineLayout({Key? key,
    required this.width,
    required this.height})
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  late Map<String, StoryTimelineData> _timelineData;
  bool loaded = false;
  bool addingStory = false;

  @override
  Widget build(BuildContext context) {
    _timelineData = BlocProvider.of<CloudStoriesBloc>(context).state.cloudStories;

    final List<Widget> children = <Widget>[];
    final List<_TimeLineEventEntry> timeLineEvents = <_TimeLineEventEntry>[];

    _timelineData.forEach((String folderId, StoryTimelineData event) {
      final Widget display = TimelineCard(
          width: widget.width,
          height: widget.height,
          event: event,
          folderId: folderId);
      final _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(event.mainStory.timestamp, display);
      timeLineEvents.add(_timeLineEventEntry);
    });

    final StringBuffer widgetKey = StringBuffer();
    widgetKey.write(_timelineData.length.toString());
    timeLineEvents.sort((_TimeLineEventEntry a, _TimeLineEventEntry b) =>
        b.timestamp.compareTo(a.timestamp));
    for (final _TimeLineEventEntry element in timeLineEvents) {
      widgetKey.write(element.timestamp.toString());
      children.add(element.event);
    }
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.refresh) {
          if (state.error != null) {
            final SnackBar snackBar = SnackBar(
              content: Text(state.error!, textAlign: TextAlign.center),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          setState(() {
            addingStory = false;
            _timelineData.forEach((String key, StoryTimelineData story) =>
                story.subEvents!.sort((StoryContent a, StoryContent b) =>
                    b.timestamp.compareTo(a.timestamp)));

            loaded = true;
          });
        }
      },
      child: !loaded
          ? StaticLoadingLogo()
          : Column(
              key: Key(widgetKey.toString()),
              children: children,
            ),
    );
  }
}
