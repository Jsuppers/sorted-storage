import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/local_stories/local_stories_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_state.dart';
import 'package:web/app/blocs/local_stories/local_stories_type.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class EventCard extends StatefulWidget {
  final Widget controls;
  final double width;
  final double height;
  final StoryContent event;
  final bool saving;
  final bool locked;
  final String eventFolderID;

  const EventCard(
      {Key key,
      this.width,
      this.height = double.infinity,
      this.event,
      this.controls,
      this.saving,
      this.eventFolderID,
      this.locked})
      : super(key: key);

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate;
  final _formKey = GlobalKey<FormState>();
  final formatter = new DateFormat('dd MMMM, yyyy');
  String formattedDate;
  List<String> uploadingImages;
  bool saving;

  @override
  void initState() {
    super.initState();
    saving = widget.saving;
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.event.timestamp);
    uploadingImages = [];
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
          parentID: widget.eventFolderID,
          folderID: widget.event.folderID,
        ),
        child: widget.event.emoji == ""
            ? Text(
                "📅",
                style: TextStyle(
                  height: 1.2,
                ),
              )
            : Text(
                widget.event.emoji,
                style: TextStyle(
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
        decoration: new InputDecoration(
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
        mode: DateFieldPickerMode.date,
        initialValue: selectedDate,
        onDateSelected: (DateTime date) {
          if (widget.saving) {
            return;
          }
          setState(
            () => BlocProvider.of<LocalStoriesBloc>(context).add(
              LocalStoriesEvent(LocalStoriesType.edit_timestamp,
                  parentID: widget.eventFolderID,
                  folderID: widget.event.folderID,
                  data: date.millisecondsSinceEpoch),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;

    List<Widget> cards = [];
    if (widget.event.images != null) {
      for (MapEntry<String, StoryMedia> image in widget.event.images.entries) {
        cards.add(imageWidget(image.key, image.value));
      }
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (context, state) {
            if (state.type == CloudStoriesType.syncing_story_state) {
              if (state.data == null) {
                return;
              }
              final Map<String, List<String>> events =
                  state.data as Map<String, List<String>>;
              if (!events.containsKey(widget.event.folderID)) {
                return;
              }
              final List<String> newUploadingImages =
                  state.data[widget.event.folderID] as List<String>;
              setState(() {
                uploadingImages = newUploadingImages;
              });
            }
          },
        ),
        BlocListener<LocalStoriesBloc, LocalStoriesState>(
            listener: (context, state) {
          if (state.type == LocalStoriesType.edit_emoji &&
              state.folderID == widget.event.folderID) {
            setState(() {
              widget.event.emoji = state.data as String;
            });
          }
        })
      ],
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            this.widget.width > Constants.SMALL_WIDTH
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          emoji(),
                          SizedBox(width: 4),
                          timeStamp(),
                        ],
                      ),
                      this.widget.controls,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          emoji(),
                          this.widget.controls,
                        ],
                      ),
                      timeStamp(),
                    ],
                  ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AbsorbPointer(
                  absorbing: widget.locked || widget.saving,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    autofocus: false,
                    maxLines: null,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        color: myThemeData.primaryColorDark),
                    decoration: new InputDecoration(
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
                    onChanged: (string) =>
                        BlocProvider.of<LocalStoriesBloc>(context).add(
                            LocalStoriesEvent(LocalStoriesType.edit_title,
                                parentID: widget.eventFolderID,
                                folderID: widget.event.folderID,
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
                      children: [
                        Container(
                          height: 40,
                          width: 140,
                          child: ButtonWithIcon(
                              text: "add media",
                              icon: Icons.image,
                              onPressed: () async {
                                if (widget.saving) {
                                  return;
                                }
                                BlocProvider.of<LocalStoriesBloc>(context).add(
                                  LocalStoriesEvent(
                                    LocalStoriesType.add_image,
                                    parentID: widget.eventFolderID,
                                    folderID: widget.event.folderID,
                                  ),
                                );
                              },
                              width: Constants.SMALL_WIDTH,
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
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter a description'),
                      readOnly: widget.locked || widget.saving,
                      onChanged: (string) {
                        BlocProvider.of<LocalStoriesBloc>(context).add(
                          LocalStoriesEvent(LocalStoriesType.edit_description,
                              parentID: widget.eventFolderID,
                              folderID: widget.event.folderID,
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
    bool showPlaceholder = media.imageURL == null;
    return RawMaterialButton(
      onPressed: () {
        if (widget.locked) {
          URLService.openDriveMedia(imageKey);
        }
      },
      child: showPlaceholder
          ? backgroundImage(showPlaceholder, imageKey, media, null)
          : Container(
              height: 150.0,
              width: 150.0,
              child: CachedNetworkImage(
                imageUrl: media.imageURL,
                placeholder: (context, url) => StaticLoadingLogo(),
                errorWidget: (context, url, error) => backgroundImage(
                    showPlaceholder,
                    imageKey,
                    media,
                    AssetImage("assets/images/error.png")),
                imageBuilder: (context, image) =>
                    backgroundImage(showPlaceholder, imageKey, media, image),
              ),
            ),
    );
  }

  Widget backgroundImage(bool showPlaceholder, String imageKey,
      StoryMedia media, ImageProvider image) {
    return Container(
      height: 150.0,
      width: 150.0,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        image: showPlaceholder
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: !widget.locked
          ? createEditControls(imageKey, showPlaceholder)
          : createNonEditControls(imageKey, showPlaceholder, media),
    );
  }

  Widget createNonEditControls(
      String imageKey, bool showPlaceholder, StoryMedia media) {
    if (showPlaceholder) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file),
            Center(child: Text(imageKey)),
          ],
        ),
      );
    }
    if (!media.isVideo && !media.isDocument) {
      return Container();
    }
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(right: 3, top: 3),
        child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
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

  Widget createEditControls(String imageKey, bool showplaceholder) {
    return Container(
      color: uploadingImages.contains(imageKey)
          ? Colors.white.withOpacity(0.5)
          : null,
      child: Column(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3, top: 3),
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
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
                          LocalStoriesEvent(LocalStoriesType.delete_image,
                              folderID: widget.event.folderID,
                              data: imageKey,
                              parentID: widget.eventFolderID));
                    },
                  ),
                ),
              )),
          Container(
            child: Column(children: [
              uploadingImages.contains(imageKey)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: StaticLoadingLogo(),
                    )
                  : Container(),
              showplaceholder
                  ? Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.saving
                            ? Container()
                            : Icon(Icons.insert_drive_file),
                        Center(child: Text(imageKey)),
                      ],
                    ))
                  : Container()
            ]),
          )
        ],
      ),
    );
  }
}
