// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/edit/edit_header.dart';
import 'package:web/ui/widgets/loading.dart';

/// page which shows a single story
class EditFolder extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditFolder(this._folderProperties, {Key? key}) : super(key: key);

  final FolderProperties? _folderProperties;

  @override
  _EditFolderState createState() => _EditFolderState();
}

class _EditFolderState extends State<EditFolder> {
  bool error = false;
  FolderProperties? folderProperties;

  @override
  void initState() {
    folderProperties = widget._folderProperties;
    super.initState();
    if (folderProperties == null) {
      BlocProvider.of<CloudStoriesBloc>(context)
          .add(CloudStoriesEvent(CloudStoriesType.createFolder));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.createFolder) {
          if (state.error != null) {
            setState(() => error = true);
          } else {
            if (state.data != null) {
              setState(() {
                folderProperties = state.data as FolderProperties;
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
        if (folderProperties == null) {
          return const FullPageLoadingLogo(backgroundColor: Colors.white);
        }

        return Padding(
            padding: const EdgeInsets.all(20.0),
            child: EditFolderContent(
              width: info.screenSize.width,
              folder: folderProperties!,
              height: info.screenSize.height,
            ));
      }),
    );
  }
}

// ignore: public_member_api_docs
class EditFolderContent extends StatefulWidget {
  // ignore: public_member_api_docs
  const EditFolderContent(
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
  final FolderProperties folder;

  @override
  _EditFolderContentState createState() => _EditFolderContentState();
}

class _EditFolderContentState extends State<EditFolderContent> {
  SavingState? savingState;

  @override
  Widget build(BuildContext context) {
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
            folder: widget.folder,
            folderID: widget.folder.id!),
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
              children: [
                EventCard(
                  savingState: savingState,
                  folder: widget.folder,
                  width: widget.width,
                  controls: Container(),
                  height: widget.height,
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
  final FolderProperties folder;

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  late String formattedDate;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
              folderID: widget.folder.id!, folder: widget.folder),
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

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.folder.title;
    // TODO save position
    titleController.selection =
        TextSelection.collapsed(offset: titleController.text.length);

    return Form(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.controls,
            emoji(),
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
                        widget.folder.title = content;
                        BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                            EditorType.updateName,
                            folderID: widget.folder.id,
                            data: '${widget.folder.emoji} $content'));
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
