import 'package:flutter/material.dart';
import 'package:web/ui/widgets/timeline.dart';

/// Page which contains all the stories
class MediaPage extends StatefulWidget {
  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
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
