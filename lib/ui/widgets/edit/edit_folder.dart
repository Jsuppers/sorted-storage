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
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/folder_image.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';

/// page which shows a single folder
class EditFolder extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditFolder({Key? key, this.folder, this.parent}) : super(key: key);

  final FolderContent? folder;
  final FolderContent? parent;

  @override
  _EditFolderState createState() => _EditFolderState();
}

class _EditFolderState extends State<EditFolder> {
  FolderContent? folder;
  FolderContent? cloudCopyFolder;
  String? folderID;
  bool error = false;

  @override
  void initState() {
    super.initState();
    if (widget.folder == null) {
      BlocProvider.of<EditorBloc>(context)
          .add(EditorEvent(EditorType.createFolder, data: widget.parent));
    } else {
      cloudCopyFolder = widget.folder;
      folder = FolderContent.clone(widget.folder!);
      folderID = folder!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState?>(
      listener: (BuildContext context, EditorState? state) {
        if (state?.type == EditorType.createFolder) {
          if (state?.error != null) {
            setState(() => error = true);
          } else if (state?.data != null) {
            FolderContent newFolder = state?.data as FolderContent;
            setState(() {
              if (folder != null) {
                folder!.subFolders!.add(FolderContent.clone(newFolder));
              } else {
                cloudCopyFolder = newFolder;
                folder = FolderContent.clone(newFolder);
              }
              FolderContent.sortFolders(folder?.subFolders);
              folderID = folder!.id;
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
        if (folder == null) {
          return const FullPageLoadingLogo(backgroundColor: Colors.white);
        }

        return Padding(
            padding: const EdgeInsets.all(20.0),
            child: EditStoryContent(
              width: info.screenSize.width,
              height: info.screenSize.height,
              folder: folder,
              cloudCopy: cloudCopyFolder,
            ));
      }),
    );
  }
}

// ignore: public_member_api_docs
class EditStoryContent extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditStoryContent({
    Key? key,
    required this.width,
    required this.height,
    required this.folder,
    required this.cloudCopy,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final FolderContent? folder;
  // ignore: public_member_api_docs
  final FolderContent? cloudCopy;

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
        automaticallyImplyLeading: false,
        floating: true,
        backgroundColor: Colors.white,
        pinned: true,
        elevation: 0.0,
        title: EditHeader(
          savingState: savingState,
          width: widget.width,
          folder: widget.folder,
        ),
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
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getCards(widget.folder!, 0),
            ),
          ),
        ),
      ),
    ]);
  }

  List<Widget> getCards(FolderContent folder, int depth) {
    List<Widget> output = [];
    output.add(EventCard(
      savingState: savingState,
      controls: Container(),
      width: widget.width,
      height: widget.height,
      folder: folder,
    ));

    if (!widget.folder!.parent!.isRootFolder) {
      output.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 40,
          width: 140,
          child: ButtonWithIcon(
              text: 'add folder',
              icon: Icons.add,
              onPressed: () async {
                if (savingState == SavingState.saving) {
                  return;
                }
                BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                    EditorType.createFolder,
                    data: widget.cloudCopy));
              },
              width: Constants.minScreenWidth,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconColor: Colors.black),
        ),
      ));
    }

    if (widget.folder!.parent!.isRootFolder ||
        folder.subFolders == null ||
        folder.subFolders!.isEmpty) {
      return output;
    }
    for (int i = 0;
        folder.subFolders != null && i < folder.subFolders!.length;
        i++) {
      output.addAll(getCards(folder.subFolders![i], depth + 1));
    }
    return output;
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
    if (widget.folder.getTimestamp() != null) {
      selectedDate = DateTime.fromMillisecondsSinceEpoch(
          widget.folder.getTimestamp()!.toInt());
      formattedDate = DateFormat('dd MMMM, yyyy').format(selectedDate);
    } else {
      selectedDate = DateTime.now();
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
          onPressed: () =>
              DialogService.emojiDialog(context, folder: widget.folder),
          child: widget.folder.emoji.isEmpty
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
                ),
        ),
      ],
    );
  }

  Widget timeStamp() {
    // root folder uses the timestamp to order it's content
    if (widget.folder.parent!.isRootFolder) {
      return Container();
    }
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
              widget.folder
                  .setTimestamp(date.millisecondsSinceEpoch.toDouble());
              BlocProvider.of<EditorBloc>(context).add(
                  EditorEvent(EditorType.updateTimestamp, data: widget.folder));
            },
          ),
        ),
      ],
    );
  }

  List<Widget> innerContent(List<FolderImage> cards) {
    if (widget.folder.parent!.isRootFolder) {
      return <Widget>[];
    }
    return [
      const SizedBox(height: 10),
      ReordableImages(
          cards: cards,
          folderID: widget.folder.id!,
          metadata: widget.folder.metadata ?? {}),
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
                  widget.folder.setDescription(content);
                  BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                      EditorType.updateImageMetadata,
                      data: widget.folder));
                });
              },
              maxLines: null),
        ],
      ),
      const SizedBox(height: 10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    String description = widget.folder
            .metadata?[describeEnum(MetadataKeys.description)] as String? ??
        '';
    titleController.text = widget.folder.title;
    titleController.selection =
        TextSelection.collapsed(offset: titleController.text.length);
    descriptionController.text = description;
    descriptionController.selection =
        TextSelection.collapsed(offset: descriptionController.text.length);

    final List<FolderImage> cards = <FolderImage>[];
    if (widget.folder.images != null) {
      for (final MapEntry<String, FolderMedia> image
          in widget.folder.images!.entries) {
        cards.add(FolderImage(
          locked: false,
          folderMedia: image.value,
          imageKey: image.key,
          folder: widget.folder,
        ));
      }
    }

    cards.sort((FolderImage a, FolderImage b) {
      final double first = a.folderMedia.getTimestamp() ?? 0;
      final double second = b.folderMedia.getTimestamp() ?? 0;
      return first.compareTo(second);
    });

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
                        widget.folder.title = content;
                        BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                            EditorType.updateName,
                            data: widget.folder));
                      });
                    }),
              ],
            ),
            ...innerContent(cards)
          ],
        ),
      ),
    );
  }
}

class ReordableImages extends StatefulWidget {
  ReordableImages(
      {required this.cards, required this.folderID, required this.metadata});

  List<FolderImage> cards;
  String folderID;
  Map<String, dynamic>? metadata;

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
                      items: <FolderImage>[...widget.cards],
                      metadata: widget.metadata ?? {},
                      folderID: widget.folderID)));

              setState(() {
                final FolderImage image = widget.cards.removeAt(oldIndex);
                widget.cards.insert(newIndex, image);
              });
            },
            children: widget.cards));
  }
}
