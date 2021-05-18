// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/sync_icon.dart';

class EditHeader extends StatefulWidget {
  // ignore: public_member_api_docs, lines_longer_than_80_chars
  EditHeader(
      {Key? key,
      this.savingState,
      required this.width,
      required this.folder,
      required this.parent})
      : super(key: key);

  final FolderContent? folder;
  final FolderContent? parent;
  final double width;
  final SavingState? savingState;

  @override
  _EditHeaderState createState() => _EditHeaderState();
}

class _EditHeaderState extends State<EditHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        color: Colors.white,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Visibility(
                  visible: widget.parent!.isRootFolder,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ButtonWithIcon(
                        text: 'share',
                        icon: Icons.share,
                        onPressed: () {
                          if (widget.savingState == SavingState.saving) {
                            return;
                          }
                          DialogService.shareDialog(
                              context, widget.folder!.id!);
                        },
                        width: widget.width,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  ),
                ),
                ButtonWithIcon(
                    text: 'delete',
                    icon: Icons.delete,
                    onPressed: () {
                      if (widget.savingState == SavingState.saving) {
                        return;
                      }
                      DialogService.showAlertDialog(context,
                          message: 'Are you sure you want to delete?',
                          callback: () {
                        UpdateFolderEvent updateEvent = UpdateFolderEvent(
                          folder: widget.folder!,
                          parent: widget.parent!,
                        );

                        BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                            EditorType.deleteFolder,
                            closeDialog: true,
                            data: updateEvent));
                      });
                    },
                    width: widget.width,
                    backgroundColor: Colors.redAccent),
                const SizedBox(width: 10),
              ],
            ),
            Row(
              children: [
                const Align(
                    alignment: Alignment.centerRight, child: SyncingIcon()),
                const SizedBox(width: 10),
                MaterialButton(
                    minWidth: 100,
                    color: myThemeData.primaryColorDark,
                    textColor: myThemeData.primaryColor,
                    onPressed: () => BlocProvider.of<NavigationBloc>(context)
                        .add(NavigatorPopEvent()),
                    child: Row(
                      children: const <Widget>[
                        Text('close'),
                      ],
                    )),
              ],
            )
          ],
        ));
  }
}

class SyncingIcon extends StatefulWidget {
  const SyncingIcon({Key? key}) : super(key: key);

  @override
  _SyncingIconState createState() => _SyncingIconState();
}

class _SyncingIconState extends State<SyncingIcon> {
  SavingState? savingState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    savingState = SavingState.none;
  }

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (savingState == SavingState.saving) {
      icon = const IconSpinner(
        icon: Icons.sync,
        isSpinning: true, // change it to true or false
      );
    } else if (savingState == SavingState.success) {
      icon = const Icon(Icons.done, color: Colors.green);
    } else if (savingState == SavingState.error) {
      icon = const Icon(Icons.error, color: Colors.red);
    } else {
      icon = Container();
    }

    return MultiBlocListener(listeners: <BlocListener<dynamic, dynamic>>[
      BlocListener<EditorBloc, EditorState?>(
          listener: (BuildContext context, EditorState? state) {
        if (state == null) {
          return;
        }
        if (state.type == EditorType.syncingState) {
          setState(() {
            savingState = state.data as SavingState;
          });
        }
      })
    ], child: icon);
  }
}
