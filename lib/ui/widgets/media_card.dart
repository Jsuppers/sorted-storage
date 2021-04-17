import 'package:flutter/material.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/ui/helpers/text_display.dart';

class MediaCard extends StatelessWidget {
  const MediaCard(this.media) : super();

  final StoryMedia media;

  String _getText() {
    if (media.name == null) {
      return '';
    }
    return TextDisplay.shortenFilename(media.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.insert_drive_file),
        Center(child: Text(_getText())),
      ],
    );
  }
}
