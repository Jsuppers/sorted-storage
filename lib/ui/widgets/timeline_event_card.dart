// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/constants.dart';
import 'package:web/ui/helpers/property.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/folder_image.dart';

///
class EventCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const EventCard(
      {Key? key,
      required this.width,
      required this.folder,
      required this.controls,
      this.height = double.infinity})
      : super(key: key);

  /// controls of the card e.g. save, edit, cancel
  final Widget controls;

  /// width of the card
  final double width;

  /// height of the card
  final double height;

  /// the story this card is related to
  final FolderContent folder;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  final DateFormat formatter = DateFormat('dd MMMM, yyyy');
  FolderContent? folder;

  @override
  void initState() {
    super.initState();
    folder = widget.folder;
    if (folder?.loaded == null || folder!.loaded == false) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: widget.folder.id,
          data: folder));
    }
  }

  Widget emoji() {
    return widget.folder.emoji.isEmpty
        ? const Text(
            '📅',
            style: TextStyle(
              height: 1.2,
            ),
          )
        : Text(
            widget.folder.emoji,
            style: const TextStyle(
              height: 1.2,
            ),
          );
  }

  Widget timeStamp() {
    final double timestamp = widget.folder.getTimestamp() ??
        DateTime.now().millisecondsSinceEpoch.toDouble();
    final DateTime selectedDate =
        DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
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

  List<Widget> subFolders() {
    List<Widget> output = [];

    if (folder!.subFolders == null || folder!.subFolders!.isEmpty) {
      return output;
    }
    for (int i = 0;
        folder!.subFolders != null && i < folder!.subFolders!.length;
        i++) {
      output.add(EventCard(
          width: widget.width,
          height: widget.height,
          folder: folder!.subFolders![i],
          controls: Container()));
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    final List<FolderImage> cards = <FolderImage>[];
    if (widget.folder.images != null) {
      for (final MapEntry<String, FolderMedia> image
          in widget.folder.images!.entries) {
        cards.add(FolderImage(
          locked: true,
          folder: widget.folder,
          folderMedia: image.value,
          imageKey: image.key,
        ));
      }
    }

    cards.sort((FolderImage a, FolderImage b) {
      final double first = a.folderMedia.getTimestamp() ?? 0;
      final double second = b.folderMedia.getTimestamp() ?? 0;
      return first.compareTo(second);
    });

    return BlocListener<CloudStoriesBloc, CloudStoriesState?>(
        listener: (BuildContext context, CloudStoriesState? state) {
          if (state == null) {
            return;
          }
          if (state.type == CloudStoriesType.retrieveFolder &&
              state.folderID == folder!.id) {
            setState(() {});
          }
        },
        child: Form(
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
                      widget.folder.title,
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
                      widget.folder
                              .metadata?[describeEnum(MetadataKeys.description)]
                          as String?,
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
              ...subFolders(),
            ]),
          ),
        ));
  }
}
