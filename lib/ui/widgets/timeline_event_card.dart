
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
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
  final EventContent event;
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
    uploadingImages =
        List(); //TimelineService.getMediaThatAreUploading(widget.event);
    formattedDate = formatter.format(selectedDate);
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
  }

  Widget emoji() {
    return AbsorbPointer(
      absorbing: widget.locked,
      child: MaterialButton(
        minWidth: 40,
        height: 40,
        onPressed: () {
          DialogService.pickEmoji(
            context,
            parentID: widget.eventFolderID,
            folderID: widget.event.folderID,
          );
        },
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
          setState(() {
            BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(
                TimelineMessageType.edit_timestamp,
                parentId: widget.eventFolderID,
                folderId: widget.event.folderID,
                timestamp: date.millisecondsSinceEpoch));
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    if (widget.event.images != null) {
      for (MapEntry<String, StoryMedia> image in widget.event.images.entries) {
        cards.add(imageWidget(image.key, image.value));
      }
    }

    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state.type == TimelineMessageType.edit_emoji &&
            state.folderID == widget.event.folderID) {
          setState(() {
            widget.event.emoji = state.data;
          });
        }

        if (state.type == TimelineMessageType.syncing_story_state) {
          if(state.uploadingImages == null) {
            return;
          }
          if (!state.uploadingImages.containsKey(widget.event.folderID)) {
            return;
          }
          List<String> newUploadingImages =
              state.uploadingImages[widget.event.folderID];
          setState(() {
            uploadingImages = newUploadingImages;
          });
        }
      },
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
                      onChanged: (string) {
                        BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(
                            TimelineMessageType.edit_title,
                            parentId: widget.eventFolderID,
                            folderId: widget.event.folderID,
                            text: string));
                        //widget.event.title = string;
                      }),
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
                                BlocProvider.of<TimelineBloc>(context).add(
                                  TimelineEvent(
                                    TimelineMessageType.add_image,
                                    parentId: widget.eventFolderID,
                                    folderId: widget.event.folderID,
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
                        BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(
                            TimelineMessageType.edit_description,
                            parentId: widget.eventFolderID,
                            folderId: widget.event.folderID,
                            text: string));
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
      child: Container(
        height: 150.0,
        width: 150.0,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          image: showPlaceholder
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(media.imageURL),
                  fit: BoxFit.cover,
                ),
        ),
        child: !widget.locked
            ? createEditControls(imageKey, showPlaceholder)
            : createNonEditControls(imageKey, showPlaceholder, media),
      ),
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
          ),);
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
                      BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(
                          TimelineMessageType.delete_image,
                          folderId: widget.event.folderID,
                          imageKey: imageKey,
                          parentId: widget.eventFolderID));
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
                      widget.saving ? Container() : Icon(Icons.insert_drive_file),
                      Center(child: Text(imageKey)),
                    ],
                  ))
                : Container()
          ]))
        ],
      ),
    );
  }
}
