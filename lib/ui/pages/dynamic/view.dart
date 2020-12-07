import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/update_adventure/update_adventure_bloc.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class ViewPage extends StatefulWidget {
  static const String route = '/view';
  final String path;

  const ViewPage({Key key, this.path}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String event;

  @override
  void initState() {
    super.initState();
    int pathLength = widget.path.length;
    int pathPrefix = ViewPage.route.length;

    event = pathLength < pathPrefix + 1
        ? null
        : widget.path.substring(pathPrefix + 1);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocProvider<UpdateAdventureBloc>(
            create: (BuildContext context) => UpdateAdventureBloc(),
            child: TimelineCard(
                viewMode: true,
                width: sizingInformation.screenSize.width,
                event: null,
                folderId: event),
          ),
        );
      },
    );
  }
}
