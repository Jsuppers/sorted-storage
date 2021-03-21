import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/widgets/icon_button.dart';

class EditHeader extends StatelessWidget {
  // ignore: public_member_api_docs
  const EditHeader(
      {Key key, this.saving, this.adventure, this.width})
      : super(key: key);

  final bool saving;
  final StoryTimelineData adventure;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
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
                      DialogService.shareDialog(
                          context,
                          adventure.mainStory.folderID,
                          adventure.mainStory.commentsID);
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                const SizedBox(width: 10),
                ButtonWithIcon(
                    text: 'delete',
                    icon: Icons.delete,
                    onPressed: () {
                      BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                          EditorType.deleteStory,
                          closeDialog: true,
                          folderID: adventure.mainStory.folderID));
                    },
                    width: width,
                    backgroundColor: Colors.redAccent),
                const SizedBox(width: 10),
                ButtonWithIcon(
                    text: 'cancel',
                    icon: Icons.cancel,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                const SizedBox(width: 10),
              ],
            ),
            Visibility(visible: saving, child: Icon(Icons.sync))
          ],
        ));
  }
}
