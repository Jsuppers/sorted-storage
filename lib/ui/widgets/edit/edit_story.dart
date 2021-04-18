import 'dart:async';

import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/story_image.dart';

/// page which shows a single story
class EditStory extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStory(this._destination, {Key? key}) : super(key: key);

  final String _destination;

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  StoryTimelineData? timelineData;
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
            StoryTimelineData? data = BlocProvider.of<CloudStoriesBloc>(context)
                .state
                .cloudStories[widget._destination];

            if (data != null) {
              setState(() {
                timelineData = StoryTimelineData.clone(data);
                timelineData!.subEvents!.sort(
                    (StoryContent a, StoryContent b) =>
                        b.timestamp.compareTo(a.timestamp));
              });
            }
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

        return Padding(
            padding: const EdgeInsets.all(20.0),
            child: EditStoryContent(
              width: info.screenSize.width,
              event: timelineData!,
              height: info.screenSize.height,
            ));
      }),
    );
  }
}

// ignore: public_member_api_docs
class EditStoryContent extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStoryContent(
      {Key? key,
      required this.width,
      required this.height,
      required this.event})
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
  SavingState? savingState;

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return const FullPageLoadingLogo(backgroundColor: Colors.white);
    }

    return CustomScrollView(slivers: [
      SliverAppBar(
        // toolbarHeight: 50,
        floating: true,
        backgroundColor: Colors.white,
        pinned: true,
        elevation: 0.0,
        title: EditHeader(
            savingState: savingState,
            width: widget.width,
            adventure: widget.event),
      ),
      SliverToBoxAdapter(
        child: MultiBlocListener(
          listeners: <BlocListener<dynamic, dynamic>>[
            BlocListener<EditorBloc, EditorState?>(
              listener: (BuildContext context, EditorState? state) {
                if (state == null) {
                  return;
                }
                if (state.type == EditorType.syncingState) {
                  savingState = state.data as SavingState;
                  if (state.refreshUI) {
                    setState(() {});
                  }
                }
                if (state.type == EditorType.deleteImage) {
                  setState(() {
                    TimelineService.removeImage(
                        state.data as String, widget.event);
                  });
                }
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventCard(
                  savingState: savingState,
                  storyFolderID: widget.event.mainStory.folderID,
                  width: widget.width,
                  controls: Container(),
                  height: widget.height,
                  story: widget.event.mainStory,
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
                          if (savingState == SavingState.saving) {
                            print('still saving');
                            return;
                          }
                          BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                              EditorType.createStory,
                              parentID: widget.event.mainStory.folderID));
                        },
                        width: Constants.minScreenWidth,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  ),
                ),
                ...List<Widget>.generate(widget.event.subEvents!.length,
                    (int index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: EventCard(
                        savingState: savingState,
                        storyFolderID: widget.event.mainStory.folderID,
                        controls: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 3, top: 3),
                            child: Container(
                              height: 34,
                              width: 34,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              child: IconButton(
                                iconSize: 18,
                                splashRadius: 18,
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () {
                                  if (savingState == SavingState.saving) {
                                    return;
                                  }
                                  BlocProvider.of<EditorBloc>(context).add(
                                      EditorEvent(EditorType.deleteStory,
                                          parentID:
                                              widget.event.mainStory.folderID,
                                          folderID: widget.event
                                              .subEvents![index].folderID));
                                },
                              ),
                            ),
                          ),
                        ),
                        width: widget.width,
                        height: widget.height,
                        story: widget.event.subEvents![index]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

///
class EventCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const EventCard(
      {Key? key,
      required this.width,
      required this.story,
      required this.controls,
      required this.storyFolderID,
      this.height = double.infinity,
      this.savingState})
      : super(key: key);

  /// controls of the card e.g. save, edit, cancel
  final Widget controls;

  /// width of the card
  final double width;

  final SavingState? savingState;

  /// height of the card
  final double height;

  /// the story this card is related to
  final StoryContent story;

  /// the folder ID of this story
  final String storyFolderID;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late DateTime selectedDate;
  late String formattedDate;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.story.timestamp);
    formattedDate = DateFormat('dd MMMM, yyyy').format(selectedDate);
  }

  Widget title(String text) {
    return Text(text, style: const TextStyle(fontSize: 10));
  }

  Widget emoji() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title('Emoji'),
        MaterialButton(
          minWidth: 40,
          height: 40,
          onPressed: () => DialogService.emojiDialog(context,
              parentID: widget.storyFolderID,
              folderID: widget.story.folderID,
              metadata: widget.story.metadata!),
          child: widget.story.metadata!.emoji.isEmpty
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
                ),
        ),
      ],
    );
  }

  Widget timeStamp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            dateTextStyle: TextStyle(
              fontSize: 12.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.normal,
              color: myThemeData.primaryColorLight,
            ),
            initialValue: selectedDate,
            onDateSelected: (DateTime date) {
              BlocProvider.of<EditorBloc>(context).add(
                EditorEvent(EditorType.updateTimestamp,
                    parentID: widget.storyFolderID,
                    folderID: widget.story.folderID,
                    data: date.millisecondsSinceEpoch),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.story.metadata!.title;
    // TODO save position
    titleController.selection =
        TextSelection.collapsed(offset: titleController.text.length);
    descriptionController.text = widget.story.metadata!.description;
    // TODO save position
    descriptionController.selection =
        TextSelection.collapsed(offset: descriptionController.text.length);

    final List<StoryImage> cards = <StoryImage>[];
    if (widget.story.images != null) {
      for (final MapEntry<String, StoryMedia> image
          in widget.story.images!.entries) {
        cards.add(StoryImage(
          locked: false,
          storyMedia: image.value,
          imageKey: image.key,
          storyFolderID: widget.storyFolderID,
          folderID: widget.story.folderID,
        ));
      }
    }

    cards.sort((StoryImage a, StoryImage b) =>
        a.storyMedia.index.compareTo(b.storyMedia.index));

    return Form(
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
                    onChanged: (String content) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        widget.story.metadata!.title = content;
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
                      BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                          EditorType.updateImagePosition,
                          parentID: widget.storyFolderID,
                          data: cards));
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
                          if (widget.savingState == SavingState.saving) {
                            return;
                          }
                          DialogService.imageUploadDialog(
                            context,
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
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        widget.story.metadata!.description = content;
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
    );
  }
}
