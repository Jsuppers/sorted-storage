import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
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
  Map<String, TimelineData> _timelineData;
  bool loaded = true;

  @override
  Widget build(BuildContext context) {
    var timelineState = BlocProvider.of<TimelineBloc>(context).state;
    if (timelineState.type == TimelineMessageType.initial_state) {
      loaded = false;
    } else {
      loaded = true;
    }
    _timelineData = timelineState.stories;
    List<Widget> eventDisplay = List();
    List<_TimeLineEventEntry> timeLineEvents = List();

    _timelineData.forEach((folderId, event) {
      Widget display = TimelineCard(
        width: widget.width,
        height: widget.height,
        event: event,
        folderId: folderId
      );
      _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(event.mainEvent.timestamp, display);
      timeLineEvents.add(_timeLineEventEntry);
    });

    String widgetKey = _timelineData.length.toString();
    timeLineEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    timeLineEvents.forEach((element) {
      widgetKey = widgetKey + element.timestamp.toString() + "";
      eventDisplay.add(element.event);
    });
    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state.type == TimelineMessageType.updated_stories) {
          setState(() {
            _timelineData = state.stories;
            _timelineData.forEach((key, story) {
              story.subEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            });

            loaded = true;
          });
        }
      },
      child: !loaded ? StaticLoadingLogo() : Column(
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
    return addingStory ? StaticLoadingLogo() : ButtonWithIcon(
        icon: Icons.add,
        text: "add story",
        width: Constants.SMALL_WIDTH,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        iconColor: Colors.black,
        onPressed: () async {
          int timestamp = DateTime.now().millisecondsSinceEpoch;
          BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(TimelineMessageType.create_story, timestamp: timestamp, mainEvent: true));
          setState(() {
            addingStory = true;
          });
        },
      );
  }
}
