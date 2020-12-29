import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

/// page which shows a single story
class ViewPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ViewPage(this._destination, {Key key}) : super(key: key);

  final String _destination;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  StoryTimelineData timelineData;
  bool error = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveStory,
        folderID: widget._destination));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.updateUI) {
          if (state.error != null) {
            setState(() => error = true);
          } else {
            setState(() {
              timelineData = BlocProvider.of<LocalStoriesBloc>(context)
                  .state
                  .localStories[widget._destination];
              timelineData.subEvents.sort((StoryContent a, StoryContent b) =>
                  b.timestamp.compareTo(a.timestamp));
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
                    Text('are you sure the link is correct?',
                      style: myThemeData.textTheme.bodyText1,),
                    Image.asset('assets/images/error.png'),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TimelineCard(
                      key: Key(timelineData.toString()),
                      viewMode: true,
                      width: info.screenSize.width,
                      event: timelineData,
                      folderId: widget._destination),
                );
        },
      ),
    );
  }
}
