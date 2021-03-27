import 'dart:async';

import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:reorderables/reorderables.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/story_image.dart';

/// page which shows a single story
class EditStory extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStory(this._destination, {Key key}) : super(key: key);

  final String _destination;

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  StoryTimelineData timelineData;
  bool error = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveStory,
        folderID: widget._destination));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.refresh) {
          if (state.error != null) {
            setState(() => error = true);
          } else {
            setState(() {
              timelineData = StoryTimelineData.clone(
                  BlocProvider.of<CloudStoriesBloc>(context)
                      .state
                      .cloudStories[widget._destination]);
              timelineData.subEvents.sort((StoryContent a, StoryContent b) =>
                  b.timestamp.compareTo(a.timestamp));
            });
          }
        }
      },
      child: ResponsiveBuilder(
          builder: (BuildContext context, SizingInformation info) {
        if (error) {
          return Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Error getting content',
                style: myThemeData.textTheme.headline3,
              ),
              Text(
                'are you sure the link is correct?',
                style: myThemeData.textTheme.bodyText1,
              ),
              Image.asset('assets/images/error.png'),
            ],
          );
        }
        if (timelineData == null) {
          return const FullPageLoadingLogo(backgroundColor: Colors.white);
        }
        print('timelineData.subEvents.length');
        print(timelineData.subEvents.length);
        return Padding(
            key: Key(timelineData.subEvents.length.toString()),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: EditStoryContent(
                width: info.screenSize.width,
                event: timelineData,
                height: info.screenSize.height,
              ),
            ));
      }),
    );
  }
}

// ignore: public_member_api_docs
class EditStoryContent extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStoryContent(
      {Key key, @required this.width, this.height, @required this.event})
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final StoryTimelineData event;

  @override
  _EditStoryContentState createState() => _EditStoryContentState();
}

class _EditStoryContentState extends State<EditStoryContent> {
  StoryTimelineData adventure;
  bool locked;
  bool saving;

  @override
  void initState() {
    super.initState();
    adventure = widget.event;
    if (adventure == null) {
      locked = true;
      saving = false;
    } else {
      locked = adventure.locked;
      saving = adventure.saving;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (adventure == null) {
      return const FullPageLoadingLogo(backgroundColor: Colors.white);
    }
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<CloudStoriesBloc, CloudStoriesState>(
          listener: (BuildContext context, CloudStoriesState state) {
//            if (state.type == CloudStoriesType.syncingStart &&
//                state.folderID == widget.folderId) {
//              setState(() {
////                saving = BlocProvider.of<LocalStoriesBloc>(context)
////                    .state
////                    .localStories[state.folderID]
////                    .saving;
//              });
//            }
//            if (state.type == CloudStoriesType.syncingEnd &&
//                state.folderID == widget.folderId) {
//              final List<String> errorMessages = state.data as List<String>;
//              if (errorMessages != null && errorMessages.isNotEmpty) {
//                DialogService.errorSyncingDialog(context,
//                    errorMessages: errorMessages);
//              }
//
//              setState(() {
//                adventure = BlocProvider.of<CloudStoriesBloc>(context)
//                    .state
//                    .cloudStories[state.folderID];
//                adventure.subEvents.sort((StoryContent a, StoryContent b) =>
//                    b.timestamp.compareTo(a.timestamp));
////                locked = adventure.locked;
////                saving = adventure.saving;
//              });
//            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventCard(
              storyFolderID: adventure.mainStory.folderID,
              saving: saving,
              controls: EditHeader(
                  saving: saving, width: widget.width, adventure: adventure),
              width: widget.width,
              height: widget.height,
              story: adventure.mainStory,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 40,
                width: 140,
                child: ButtonWithIcon(
                    text: 'add sub-event',
                    icon: Icons.add,
                    onPressed: () async {
                      if (saving) {
                        return;
                      }
                      BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                          EditorType.createStory,
                          parentID: adventure.mainStory.folderID));
                    },
                    width: Constants.minScreenWidth,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
              ),
            ),
            ...List<Widget>.generate(adventure.subEvents.length, (int index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: EventCard(
                    storyFolderID: adventure.mainStory.folderID,
                    saving: saving,
                    controls: Container(),
                    width: widget.width,
                    height: widget.height,
                    story: adventure.subEvents[index]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ignore: public_member_api_docs
class SavingIcon extends StatefulWidget {
  // ignore: public_member_api_docs
  const SavingIcon({
    Key key,
    this.folderID,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String folderID;

  @override
  _SavingIconState createState() => _SavingIconState();
}

class _SavingIconState extends State<SavingIcon> {
  double percent = 0;
  String text = '0%';

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
//        if (state.type == CloudStoriesType.progressUpload &&
//            state.folderID == widget.folderID) {
//          final MediaProgress progress = state.data as MediaProgress;
//          setState(() {
//            // TODO this shows file loading progress not sending progress
//            final int total =
//                progress.total + 1; // we will be evil and never show 100%
//            final int sent = progress.sent;
//            if (sent == 0) {
//              percent = 0;
//            } else {
//              percent = sent / total;
//            }
//            text = '${(percent * 100).toInt()}%';
//          });
//        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircularPercentIndicator(
            radius: 48.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text(
              text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: myThemeData.accentColor,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}

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
      this.storyFolderID})
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
  Timer _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    saving = widget.saving;
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.story.timestamp);
    uploadingImages = <String>[];
    formattedDate = formatter.format(selectedDate);
  }

  Widget title(String text) {
    return Text(text, style: const TextStyle(fontSize: 10));
  }

  Widget emoji() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title('Emoji'),
        MaterialButton(
          minWidth: 40,
          height: 40,
          onPressed: () => DialogService.emojiDialog(context,
              parentID: widget.storyFolderID,
              folderID: widget.story.folderID,
              metadata: widget.story.metadata),
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
      ],
    );
  }

  Widget timeStamp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title('Date'),
        Container(
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
                () => BlocProvider.of<EditorBloc>(context).add(
                  EditorEvent(EditorType.updateTimestamp,
                      parentID: widget.storyFolderID,
                      folderID: widget.story.folderID,
                      data: date.millisecondsSinceEpoch),
                ),
              );
            },
          ),
        ),
      ],
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
          locked: false,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.controls,
              emoji(),
              const SizedBox(height: 10),
              timeStamp(),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title('Title'),
                  TextFormField(
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
                      controller: titleController,
                      onEditingComplete: () => {print('saved')},
                      onChanged: (String content) {
                        if (_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                          widget.story.metadata.title = content;
                          BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                              EditorType.updateMetadata,
                              parentID: widget.storyFolderID,
                              folderID: widget.story.folderID,
                              data: widget.story.metadata));
                        });
                      }),
                ],
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
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
                            DialogService.imageUploadDialog(context,
                              folderID: widget.story.folderID,
                              parentID: widget.storyFolderID,
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
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title('Description'),
                  TextFormField(
                      controller: descriptionController,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'OpenSans',
                          color: myThemeData.primaryColorDark),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter a description'),
                      onChanged: (String content) {
                        if (_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                          widget.story.metadata.description = content;
                          BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                              EditorType.updateMetadata,
                              parentID: widget.storyFolderID,
                              folderID: widget.story.folderID,
                              data: widget.story.metadata));
                        });
                      },
                      maxLines: null),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
