import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class _TimeLineEventEntry {
  final int timestamp;
  final Widget event;

  _TimeLineEventEntry(this.timestamp, this.event);
}

class TimelineLayout extends StatefulWidget {
  final double width;
  final double height;

  const TimelineLayout({Key key, this.width, this.height}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  Map<String, StoryTimelineData> _timelineData;
  bool loaded = true;

  @override
  Widget build(BuildContext context) {
    var timelineState = BlocProvider.of<CloudStoriesBloc>(context).state;
    loaded = timelineState.type == CloudStoriesType.initialState ? false : true;
    _timelineData = BlocProvider.of<LocalStoriesBloc>(context).state.localStories;
    List<Widget> eventDisplay = [];
    List<_TimeLineEventEntry> timeLineEvents = [];

    _timelineData.forEach((folderId, StoryTimelineData event) {
      Widget display = TimelineCard(
          width: widget.width,
          height: widget.height,
          event: event,
          folderId: folderId);
      _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(event.mainStory.timestamp, display);
      timeLineEvents.add(_timeLineEventEntry);
    });

    String widgetKey = _timelineData.length.toString();
    timeLineEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    timeLineEvents.forEach((element) {
      widgetKey = widgetKey + element.timestamp.toString() + "";
      eventDisplay.add(element.event);
    });
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (context, state) {
        if (state.type == CloudStoriesType.updateUI) {
          setState(() {
            print('updating stories');
            _timelineData.forEach((key, story) => story.subEvents
                .sort((a, b) => b.timestamp.compareTo(a.timestamp)));
            loaded = true;
          });
        }
      },
      child: !loaded
          ? StaticLoadingLogo()
          : Column(
              key: Key(widgetKey),
              children: [
                Container(
                  width: 150,
                  child: AddStoryButton(),
                ),
                SizedBox(height: 20),
                ...eventDisplay,
              ],
            ),
    );
  }
}

class AddStoryButton extends StatefulWidget {
  const AddStoryButton({
    Key key,
  }) : super(key: key);

  @override
  _AddStoryButtonState createState() => _AddStoryButtonState();
}

class _AddStoryButtonState extends State<AddStoryButton> {
  bool addingStory;

  @override
  void initState() {
    super.initState();
    addingStory = false;
  }

  @override
  Widget build(BuildContext context) {
    return addingStory
        ? StaticLoadingLogo()
        : ButtonWithIcon(
            icon: Icons.add,
            text: "add story",
            width: Constants.SMALL_WIDTH,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            iconColor: Colors.black,
            onPressed: () async {
              int timestamp = DateTime.now().millisecondsSinceEpoch;
              BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
                  CloudStoriesType.createStory,
                  data: timestamp,
                  mainEvent: true));
              setState(() => addingStory = true);
            },
          );
  }
}
