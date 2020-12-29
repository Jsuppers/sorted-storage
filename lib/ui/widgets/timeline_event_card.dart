import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';

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
        child: widget.story.emoji.isEmpty
            ? const Text(
                '📅',
                style: TextStyle(
                  height: 1.2,
                ),
              )
            : Text(
                widget.story.emoji,
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
          setState(
            () => BlocProvider.of<LocalStoriesBloc>(context).add(
              LocalStoriesEvent(LocalStoriesType.editTimestamp,
                  parentID: widget.storyFolderID,
                  folderID: widget.story.folderID,
                  data: date.millisecondsSinceEpoch),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.story.title;
    descriptionController.text = widget.story.description;

    final List<Widget> cards = <Widget>[];
    if (widget.story.images != null) {
      for (final MapEntry<String, StoryMedia> image
          in widget.story.images.entries) {
        cards.add(imageWidget(image.key, image.value));
      }
    }

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (BuildContext context, CloudStoriesState state) {
            if (state.type == CloudStoriesType.syncingState) {
              if (state.data == null) {
                return;
              }
              final Map<String, List<String>> events =
                  state.data as Map<String, List<String>>;
              if (!events.containsKey(widget.story.folderID)) {
                return;
              }
              final List<String> newUploadingImages =
                  state.data[widget.story.folderID] as List<String>;
              setState(() {
                uploadingImages = newUploadingImages;
              });
            }
          },
        ),
        BlocListener<LocalStoriesBloc, LocalStoriesState>(
            listener: (BuildContext context, LocalStoriesState state) {
          if (state.type == LocalStoriesType.editEmoji &&
              state.folderID == widget.story.folderID) {
            setState(() {
              widget.story.emoji = state.data as String;
            });
          }
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
                    onChanged: (String string) =>
                        BlocProvider.of<LocalStoriesBloc>(context).add(
                            LocalStoriesEvent(LocalStoriesType.editTitle,
                                parentID: widget.storyFolderID,
                                folderID: widget.story.folderID,
                                data: string)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: cards,
                  ),
                ),
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
                                BlocProvider.of<LocalStoriesBloc>(context).add(
                                  LocalStoriesEvent(
                                    LocalStoriesType.addImage,
                                    parentID: widget.storyFolderID,
                                    folderID: widget.story.folderID,
                                  ),
                                );
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
                        BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.editDescription,
                              parentID: widget.storyFolderID,
                              folderID: widget.story.folderID,
                              data: string),
                        );
                      },
                      maxLines: null),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget imageWidget(String imageKey, StoryMedia media) {
    final bool showPlaceholder = media.thumbnailURL == null;
    return RawMaterialButton(
      onPressed: () {
        if (widget.locked) {
          URLService.openDriveMedia(imageKey);
        }
      },
      child: showPlaceholder
          ? _backgroundImage(showPlaceholder, imageKey, media, null)
          : SizedBox(
              height: 150.0,
              width: 150.0,
              child: CachedNetworkImage(
                imageUrl: media.thumbnailURL,
                placeholder: (BuildContext context, String url) =>
                    StaticLoadingLogo(),
                errorWidget:
                    (BuildContext context, String url, dynamic error) =>
                        _backgroundImage(showPlaceholder, imageKey, media,
                            const AssetImage('assets/images/error.png')),
                imageBuilder: (BuildContext context,
                        ImageProvider<Object> image) =>
                    _backgroundImage(showPlaceholder, imageKey, media, image),
              ),
            ),
    );
  }

  Widget _backgroundImage(bool showPlaceholder, String imageKey,
      StoryMedia media, ImageProvider image) {
    return Container(
      height: 150.0,
      width: 150.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        image: showPlaceholder
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: !widget.locked
          ? _createEditControls(imageKey, showPlaceholder)
          : _createNonEditControls(imageKey, showPlaceholder, media),
    );
  }

  Widget _createNonEditControls(
      String imageKey, bool showPlaceholder, StoryMedia media) {
    if (showPlaceholder) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.insert_drive_file),
          Center(child: Text(imageKey)),
        ],
      );
    }
    if (!media.isVideo && !media.isDocument) {
      return Container();
    }
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(right: 3, top: 3),
        child: Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: Icon(
            media.isVideo ? Icons.play_arrow : Icons.insert_drive_file,
            color: Colors.black,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _createEditControls(String imageKey, bool showPlaceholder) {
    return Container(
      color: uploadingImages.contains(imageKey)
          ? Colors.white.withOpacity(0.5)
          : null,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3, top: 3),
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: IconButton(
                    iconSize: 18,
                    splashRadius: 18,
                    icon: Icon(
                      widget.saving ? Icons.cloud_upload : Icons.clear,
                      color: widget.saving
                          ? (uploadingImages.contains(imageKey)
                              ? Colors.orange
                              : Colors.green)
                          : Colors.redAccent,
                      size: 18,
                    ),
                    onPressed: () {
                      if (widget.saving) {
                        return;
                      }
                      BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.deleteImage,
                              folderID: widget.story.folderID,
                              data: imageKey,
                              parentID: widget.storyFolderID));
                    },
                  ),
                ),
              )),
          Column(children: <Widget>[
            if (uploadingImages.contains(imageKey))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: StaticLoadingLogo(),
              )
            else
              Container(),
            if (showPlaceholder)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.saving)
                    Container()
                  else
                    const Icon(Icons.insert_drive_file),
                  Center(child: Text(imageKey)),
                ],
              )
            else
              Container()
          ])
        ],
      ),
    );
  }
}
