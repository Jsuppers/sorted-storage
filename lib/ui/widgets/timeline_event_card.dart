// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/constants.dart';
import 'package:web/ui/helpers/property.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/story_image.dart';

///
class EventCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const EventCard(
      {Key? key,
      required this.width,
      required this.story,
      required this.controls,
      required this.storyFolderID,
      required this.locked,
      this.height = double.infinity})
      : super(key: key);

  /// controls of the card e.g. save, edit, cancel
  final Widget controls;

  /// width of the card
  final double width;

  /// height of the card
  final double height;

  /// the story this card is related to
  final StoryContent story;

  /// whether the card is locked
  final bool locked;

  /// the folder ID of this story
  final String storyFolderID;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  final DateFormat formatter = DateFormat('dd MMMM, yyyy');

  Widget emoji() {
    return widget.story.metadata!.emoji.isEmpty
        ? const Text(
            '📅',
            style: TextStyle(
              height: 1.2,
            ),
          )
        : Text(
            widget.story.metadata!.emoji,
            style: const TextStyle(
              height: 1.2,
            ),
          );
  }

  Widget timeStamp() {
    final DateTime selectedDate =
        DateTime.fromMillisecondsSinceEpoch(widget.story.timestamp);
    final String formattedDate = formatter.format(selectedDate);
    return Container(
      padding: EdgeInsets.zero,
      height: 38,
      width: 130,
      child: Text(formattedDate,
          style: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
            color: myThemeData.primaryColorLight,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<StoryImage> cards = <StoryImage>[];
    if (widget.story.images != null) {
      for (final MapEntry<String, StoryMedia> image
          in widget.story.images!.entries) {
        cards.add(StoryImage(
          locked: widget.locked,
          storyMedia: image.value,
          imageKey: image.key,
          storyFolderID: widget.storyFolderID,
          id: widget.story.folderID,
        ));
      }
    }

    cards.sort((StoryImage a, StoryImage b) =>
        a.storyMedia.order!.compareTo(b.storyMedia.order!));

    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: <Widget>[
          if (widget.width > Constants.minScreenWidth)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    emoji(),
                    const SizedBox(width: 4),
                    timeStamp(),
                  ],
                ),
                widget.controls,
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    emoji(),
                    widget.controls,
                  ],
                ),
                timeStamp(),
              ],
            ),
          Column(
            children: <Widget>[
              Text(
                Property.getValueOrDefault(
                  widget.story.metadata!.title,
                  'No title given',
                ),
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                    color: myThemeData.primaryColorDark),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                      key: Key(DateTime.now().toString()),
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: cards)),
              Text(
                Property.getValueOrDefault(
                  widget.story.metadata!.description,
                  'No description given',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'OpenSans',
                    color: myThemeData.primaryColorDark),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
