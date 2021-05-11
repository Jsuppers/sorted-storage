// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:date_field/date_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
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
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/pages/dynamic/folders.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/story_image.dart';

/// page which shows a single story
class EditStory extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStory(this._destination, {Key? key, this.parent}) : super(key: key);

  final String? _destination;
  final FolderContent? parent;

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  FolderContent? timelineData;
  bool error = false;
  late String? folderID;

  @override
  void initState() {
    super.initState();
    folderID = widget._destination;
    if (folderID != null) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: folderID));
    } else {
      BlocProvider.of<EditorBloc>(context)
          .add(EditorEvent(EditorType.createStory, data: widget.parent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
    if (state.type == CloudStoriesType.retrieveFolder
    && state.folderID == widget._destination) {
      if (state.data != null) {
        setState(() {
          timelineData = FolderContent.clone(state.data as FolderContent);
          timelineData!.subFolders!.sort(
                  (FolderContent a, FolderContent b) =>
                  b.order!.compareTo(a.order!));
        });
      }
    }
        if (state.type == CloudStoriesType.refresh) {
          if (state.error != null) {
            setState(() => error = true);
          } else {
            if (state.folderID != null) {
              folderID = state.folderID;
            }
            FolderContent? data = TimelineService.getFolderWithID(folderID!,
                BlocProvider.of<CloudStoriesBloc>(context).rootFolder);

            if (data != null) {
              setState(() {
                timelineData = FolderContent.clone(data);
                timelineData!.subFolders!.sort(
                    (FolderContent a, FolderContent b) =>
                        b.order!.compareTo(a.order!));
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
              height: info.screenSize.height,
              folder: timelineData,
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
      required this.folder})
      : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final FolderContent? folder;

  @override
  _EditStoryContentState createState() => _EditStoryContentState();
}

class _EditStoryContentState extends State<EditStoryContent> {
  SavingState? savingState;

  @override
  Widget build(BuildContext context) {
    if (widget.folder == null) {
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
            folder: widget.folder),
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
                        state.data as String, widget.folder);
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
                FolderPage(widget.folder!.id!),
                EventCard(
                  savingState: savingState,
                  width: widget.width,
                  controls: Container(),
                  height: widget.height,
                  folder: widget.folder!,
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
                              data: widget.folder));
                        },
                        width: Constants.minScreenWidth,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  ),
                ),
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
      required this.folder,
      required this.controls,
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
  final FolderContent folder;

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
    if (widget.folder.order != null) {
      selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.folder.order!.toInt());
      formattedDate = DateFormat('dd MMMM, yyyy').format(selectedDate);
    }
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
              folderID: widget.folder.id!,
              folder: widget.folder,
              metadata: widget.folder.metadata!),
          child: widget.folder.metadata!.emoji.isEmpty
              ? const Text(
                  '📅',
                  style: TextStyle(
                    height: 1.2,
                  ),
                )
              : Text(
                  widget.folder.metadata!.emoji,
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
              BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                  EditorType.updateTimestamp,
                  data: UpdateOrderEvent(
                      order: date.millisecondsSinceEpoch.toDouble(),
                      folderContent: widget.folder)));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.folder.metadata!.title;
    // TODO save position
    titleController.selection =
        TextSelection.collapsed(offset: titleController.text.length);
    descriptionController.text = widget.folder.metadata!.description;
    // TODO save position
    descriptionController.selection =
        TextSelection.collapsed(offset: descriptionController.text.length);

    final List<StoryImage> cards = <StoryImage>[];
    if (widget.folder.images != null) {
      for (final MapEntry<String, StoryMedia> image
          in widget.folder.images!.entries) {
        cards.add(StoryImage(
          locked: false,
          storyMedia: image.value,
          imageKey: image.key,
          id: widget.folder.id!,
        ));
      }
    }

    cards.sort((StoryImage a, StoryImage b) =>
        a.storyMedia.order!.compareTo(b.storyMedia.order!));

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
                        widget.folder.metadata!.title = content;

                        BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                            EditorType.updateMetadata,
                            data: UpdateMetaDataEvent(
                                metaData: widget.folder.metadata!,
                                folderContent: widget.folder)));
                      });
                    }),
              ],
            ),
            const SizedBox(height: 10),
            ReordableImages(
                cards: cards,
                folderID: widget.folder.id!),
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
                            folder: widget.folder,
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
                        widget.folder.metadata!.description = content;
                        BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                            EditorType.updateMetadata,
                            data: UpdateMetaDataEvent(
                                metaData: widget.folder.metadata!,
                                folderContent: widget.folder)));
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

class ReordableImages extends StatefulWidget {
  ReordableImages({required this.cards, required this.folderID});

  List<StoryImage> cards;
  String folderID;

  @override
  _ReordableImagesState createState() => _ReordableImagesState();
}

class _ReordableImagesState extends State<ReordableImages> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        key: Key(DateTime.now().toString()),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ReorderableWrap(
            spacing: 8.0,
            runSpacing: 4.0,
            padding: const EdgeInsets.all(8),
            onReorder: (int oldIndex, int newIndex) {
              BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                  EditorType.updateImagePosition,
                  folderID: widget.folderID,
                  data: UpdatePosition(
                      media: true,
                      currentIndex: oldIndex,
                      targetIndex: newIndex,
                      items: <StoryImage>[...widget.cards],
                      folderID: widget.folderID)));

              setState(() {
                final StoryImage image = widget.cards.removeAt(oldIndex);
                widget.cards.insert(newIndex, image);
              });
            },
            children: widget.cards));
  }
}
