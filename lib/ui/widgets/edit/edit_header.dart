import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/sync_icon.dart';

class EditHeader extends StatefulWidget {
  // ignore: public_member_api_docs, lines_longer_than_80_chars
  EditHeader({
    Key key,
    this.savingState,
    this.adventure,
    this.width}) : super(key: key);

  final StoryTimelineData adventure;
  final double width;
  final SavingState savingState;

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
                    ButtonWithIcon(
                        text: 'share',
                        icon: Icons.share,
                        onPressed: () {
                          if(widget.savingState == SavingState.saving) {
                            return;
                          }
                          DialogService.shareDialog(
                              context,
                              widget.adventure.mainStory.folderID,
                              widget.adventure.mainStory.commentsID);
                        },
                        width: widget.width,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                    const SizedBox(width: 10),
                    ButtonWithIcon(
                        text: 'delete',
                        icon: Icons.delete,
                        onPressed: () {
                          if(widget.savingState == SavingState.saving) {
                            return;
                          }
                          BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                              EditorType.deleteStory,
                              closeDialog: true,
                              folderID: widget.adventure.mainStory.folderID));
                        },
                        width: widget.width,
                        backgroundColor: Colors.redAccent),
                    const SizedBox(width: 10),
                  ],
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: SyncingIcon(savingState: widget.savingState)),
              ],
            ));
  }
}

class SyncingIcon extends StatelessWidget {

  const SyncingIcon({Key key, this.savingState}) : super(key: key);

  final SavingState savingState;

  @override
  Widget build(BuildContext context) {
    if (savingState == SavingState.saving) {
      return const IconSpinner(
          icon: Icons.sync,
          isSpinning: true,  // change it to true or false
        );
    }
    if (savingState == SavingState.success) {
      return const Icon(Icons.done, color: Colors.green);
    }
    if (savingState == SavingState.error) {
      return const Icon(Icons.error, color: Colors.red);
    }

    return Container();
  }
}

