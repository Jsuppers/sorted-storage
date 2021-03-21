import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/story_image.dart';

///
class EventCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const EventCard(
      {Key key,
      this.width,
      this.height = double.infinity,
      this.story,
      this.controls,
      this.saving,
      this.storyFolderID,
      this.locked})
      : super(key: key);

  /// controls of the card e.g. save, edit, cancel
  final Widget controls;

  /// width of the card
  final double width;

  /// height of the card
  final double height;

  /// the story this card is related to
  final StoryContent story;

  /// whether we are currently saving
  final bool saving;

  /// whether the card is locked
  final bool locked;

  /// the folder ID of this story
  final String storyFolderID;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate;
  final GlobalKey _formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat('dd MMMM, yyyy');
  String formattedDate;
  List<String> uploadingImages;
  bool saving;

  @override
  void initState() {
    super.initState();
    saving = widget.saving;
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.story.timestamp);
    uploadingImages = <String>[];
    formattedDate = formatter.format(selectedDate);
  }

  Widget emoji() {
    return AbsorbPointer(
      absorbing: widget.locked,
      child: MaterialButton(
        minWidth: 40,
        height: 40,
        onPressed: () => DialogService.emojiDialog(
          context,
          parentID: widget.storyFolderID,
          folderID: widget.story.folderID,
        ),
        child: widget.story.metadata.emoji.isEmpty
            ? const Text(
                '📅',
                style: TextStyle(
                  height: 1.2,
                ),
              )
            : Text(
                widget.story.metadata.emoji,
                style: const TextStyle(
                  height: 1.2,
                ),
              ),
      ),
    );
  }

  Widget timeStamp() {
    return Container(
      padding: EdgeInsets.zero,
      height: 38,
      width: 130,
      child: DateTimeFormField(
        decoration: const InputDecoration(
            errorBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero),
        enabled: !widget.locked,
        textStyle: TextStyle(
          fontSize: 12.0,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.normal,
          color: myThemeData.primaryColorLight,
        ),
        label: null,
        initialValue: selectedDate,
        onDateSelected: (DateTime date) {
          if (widget.saving) {
            return;
          }
//          setState(
//            () => BlocProvider.of<CloudStoriesBloc>(context).add(
//              CloudStoriesEvent(CloudStoriesType.editTimestamp,
//                  parentID: widget.storyFolderID,
//                  folderID: widget.story.folderID,
//                  data: date.millisecondsSinceEpoch),
//            ),
//          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.story.metadata.title;
    descriptionController.text = widget.story.metadata.description;

    final List<StoryImage> cards = <StoryImage>[];
    if (widget.story.images != null) {
      for (final MapEntry<String, StoryMedia> image
          in widget.story.images.entries) {
        cards.add(StoryImage(
          locked: widget.locked,
          saving: widget.saving,
          uploadingImages: uploadingImages,
          storyMedia: image.value,
          imageKey: image.key,
          storyFolderID: widget.storyFolderID,
          folderID: widget.story.folderID,
        ));
      }
    }

    cards.sort((StoryImage a, StoryImage b) =>
        a.storyMedia.index.compareTo(b.storyMedia.index));

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (BuildContext context, CloudStoriesState state) {
//            if (state.type == CloudStoriesType.syncingState) {
//              if (state.data == null) {
//                return;
//              }
//              final Map<String, List<String>> events =
//                  state.data as Map<String, List<String>>;
//              if (!events.containsKey(widget.story.folderID)) {
//                return;
//              }
//              final List<String> newUploadingImages =
//                  state.data[widget.story.folderID] as List<String>;
//              setState(() {
//                uploadingImages = newUploadingImages;
//              });
//            }
          },
        ),
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
            listener: (BuildContext context, CloudStoriesState state) {
//          if (state.type == CloudStoriesType.editEmoji &&
//              state.folderID == widget.story.folderID) {
//            setState(() {
//              widget.story.emoji = state.data as String;
//            });
//          }
        })
      ],
      child: Form(
        key: _formKey,
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
                AbsorbPointer(
                  absorbing: widget.locked || widget.saving,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    maxLines: null,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        color: myThemeData.primaryColorDark),
                    decoration: const InputDecoration(
                        errorMaxLines: 0,
                        errorBorder: InputBorder.none,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Enter a title'),
                    readOnly: widget.locked || widget.saving,
                    controller: titleController,
                    onChanged: (String string) => print('exception should be called')
//                        BlocProvider.of<CloudStoriesBloc>(context).add(
//                            CloudStoriesEvent(CloudStoriesType.update,
//                                parentID: widget.storyFolderID,
//                                folderID: widget.story.folderID)),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ReorderableWrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        padding: const EdgeInsets.all(8),
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            final StoryImage image = cards.removeAt(oldIndex);
                            cards.insert(newIndex, image);
                            for (int i = 0; i < cards.length; i++) {
                              cards[i].storyMedia.index = i;
                            }
                          });
                        },
                        children: cards)),
                Visibility(
                  visible: !widget.locked,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          width: 140,
                          child: ButtonWithIcon(
                              text: 'add media',
                              icon: Icons.image,
                              onPressed: () async {
                                if (widget.saving) {
                                  return;
                                }
                                // TODO add image
//                                BlocProvider.of<LocalStoriesBloc>(context)
//                                    .add(
//                                  LocalStoriesEvent(
//                                    LocalStoriesType.addImage,
//                                    parentID: widget.storyFolderID,
//                                    folderID: widget.story.folderID,
//                                  ),
//                                );
                              },
                              width: Constants.minScreenWidth,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              iconColor: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                AbsorbPointer(
                  absorbing: widget.locked || widget.saving,
                  child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: descriptionController,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'OpenSans',
                          color: myThemeData.primaryColorDark),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter a description'),
                      readOnly: widget.locked || widget.saving,
                      onChanged: (String string) {
//                        BlocProvider.of<CloudStoriesBloc>(context).add(
//                          CloudStoriesEvent(CloudStoriesType.update,
//                              parentID: widget.storyFolderID,
//                              folderID: widget.story.folderID),
//                        );
                      },
                      maxLines: null),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
