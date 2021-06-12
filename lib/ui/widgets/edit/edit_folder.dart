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
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/folder_image.dart';
import 'package:web/ui/widgets/folders_list.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';

/// page which shows a single folder
class EditFolder extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditFolder({Key? key, this.folder, this.parent}) : super(key: key);

  final Folder? folder;

  /// we have a parent folder here instead of folder.parent because folder
  /// can be null, which will create a new folder in this parent
  final Folder? parent;

  @override
  _EditFolderState createState() => _EditFolderState();
}

class _EditFolderState extends State<EditFolder> {
  Folder? folder;
  bool error = false;

  @override
  void initState() {
    super.initState();
    if (widget.folder == null) {
      BlocProvider.of<EditorBloc>(context)
          .add(EditorEvent(EditorType.createFolder, data: widget.parent));
    } else {
      folder = widget.folder;
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
            setState(() {
              final Folder newFolder = state?.data as Folder;
              if (folder != null) {
                Folder.sortFoldersByTimestamp(folder?.subFolders);
              } else {
                folder = newFolder;
              }
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
            child: EditFolderContent(
              width: info.screenSize.width,
              height: info.screenSize.height,
              folder: folder,
            ));
      }),
    );
  }
}

// ignore: public_member_api_docs
class EditFolderContent extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditFolderContent({
    Key? key,
    required this.width,
    required this.height,
    required this.folder,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final Folder? folder;

  @override
  _EditFolderContentState createState() => _EditFolderContentState();
}

class _EditFolderContentState extends State<EditFolderContent> {
  SavingState? savingState;
  Folder? folder;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folder = widget.folder;
  }

  @override
  Widget build(BuildContext context) {
    if (folder == null) {
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
          folder: folder,
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
              children: getCards(0),
            ),
          ),
        ),
      ),
    ]);
  }

  List<Widget> getCards(int depth) {
    final List<Widget> output = <Widget>[];
    output.add(EventCard(
      savingState: savingState,
      controls: Container(),
      width: widget.width,
      height: widget.height,
      folder: folder!,
    ));

    if (folder!.parent == null || folder!.parent!.isRootFolder == false) {
      output.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Folders', style: myThemeData.textTheme.headline4),
            SizedBox(
              height: 40,
              width: 140,
              child: ButtonWithIcon(
                  text: 'add folder',
                  icon: Icons.add,
                  onPressed: () async {
                    if (savingState == SavingState.saving) {
                      return;
                    }
                    BlocProvider.of<EditorBloc>(context).add(
                        EditorEvent(EditorType.createFolder, data: folder));
                  },
                  width: Constants.minScreenWidth,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  iconColor: Colors.black),
            ),
          ],
        ),
      ));
    }

    if (folder!.parent?.isRootFolder == true || folder!.subFolders.isEmpty) {
      return output;
    }
    output.add(FoldersList(
      subFolders: folder!.subFolders,
      subFolderClick: (subFolder) {
        setState(() {
          folder = subFolder;
        });
      },
    ));
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

  /// the folder this card is related to
  final Folder folder;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late DateTime selectedDate;
  late String formattedDate;
  late Map<String, dynamic> editingMetaData;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    editingMetaData = Map<String, dynamic>.from(widget.folder.metadata);
    if (widget.folder.metadata.getTimestamp() != null) {
      selectedDate = DateTime.fromMillisecondsSinceEpoch(
          widget.folder.metadata.getTimestamp()!.toInt());
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
    if (widget.folder.parent?.isRootFolder == true) {
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
              editingMetaData.setTimestamp(date.millisecondsSinceEpoch);
              final UpdateMetadataEvent update = UpdateMetadataEvent(
                data: widget.folder,
                metadata: editingMetaData,
              );
              BlocProvider.of<EditorBloc>(context)
                  .add(EditorEvent(EditorType.updateMetadata, data: update));
            },
          ),
        ),
      ],
    );
  }

  List<Widget> innerContent(List<FolderImage> cards) {
    if (widget.folder.parent?.isRootFolder == true) {
      return <Widget>[];
    }
    return [
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
                  editingMetaData.setDescription(content);
                  final UpdateMetadataEvent update = UpdateMetadataEvent(
                    data: widget.folder,
                    metadata: editingMetaData,
                  );
                  BlocProvider.of<EditorBloc>(context).add(
                      EditorEvent(EditorType.updateMetadata, data: update));
                });
              },
              maxLines: null),
        ],
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Files', style: myThemeData.textTheme.headline4),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 40,
                width: 140,
                child: ButtonWithIcon(
                    text: 'add file',
                    icon: Icons.file_upload,
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
      ]),
      ReordableImages(cards: cards, folder: widget.folder),
      const SizedBox(height: 10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.folder.title;
    titleController.selection =
        TextSelection.collapsed(offset: titleController.text.length);
    descriptionController.text = widget.folder.metadata.getDescription();
    descriptionController.selection =
        TextSelection.collapsed(offset: descriptionController.text.length);

    final List<FolderImage> cards = <FolderImage>[];
    for (final MapEntry<String, FileData> image
        in widget.folder.files.entries) {
      cards.add(FolderImage(
        locked: false,
        folderMedia: image.value,
        imageKey: image.key,
        folder: widget.folder,
      ));
    }

    cards.sort((FolderImage a, FolderImage b) {
      final double first = a.folderMedia.metadata.getOrder() ?? 0;
      final double second = b.folderMedia.metadata.getOrder() ?? 0;
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
                        final String fileName =
                            FolderNameData.toFileNameFromEmojiAndTitle(
                                widget.folder.emoji, content);
                        final UpdateFilenameEvent update = UpdateFilenameEvent(
                            filename: fileName, folder: widget.folder);
                        BlocProvider.of<EditorBloc>(context).add(
                            EditorEvent(EditorType.updateName, data: update));
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
  ReordableImages({required this.cards, required this.folder});

  List<FolderImage> cards;
  Folder folder;

  @override
  _ReordableImagesState createState() => _ReordableImagesState();
}

class _ReordableImagesState extends State<ReordableImages> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ReorderableWrap(
            spacing: 8.0,
            runSpacing: 4.0,
            padding: const EdgeInsets.all(8),
            onReorder: (int oldIndex, int newIndex) {
              BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                  EditorType.updatePosition,
                  folderID: widget.folder.id,
                  data: UpdatePosition(
                      media: true,
                      currentIndex: oldIndex,
                      targetIndex: newIndex,
                      items: <FolderImage>[...widget.cards],
                      folder: widget.folder)));

              setState(() {
                final FolderImage image = widget.cards.removeAt(oldIndex);
                widget.cards.insert(newIndex, image);
              });
            },
            children: widget.cards));
  }
}
