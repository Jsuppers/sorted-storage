import 'package:flutter/material.dart';
import 'package:web/ui/widgets/timeline.dart';

class MediaPage extends StatefulWidget {
  static const String route = '/media';

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TimelineLayout(
              width: constraints.maxWidth, height: constraints.maxHeight);
        },
      ),
    );
  }
}
