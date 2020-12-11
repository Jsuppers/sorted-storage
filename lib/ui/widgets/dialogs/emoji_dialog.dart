import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/ui/widgets/emoji_picker.dart';

class EmojiDialog extends StatelessWidget {
  final String parentID;
  final String folderID;

  const EmojiDialog({Key key, this.parentID, this.folderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: Container(
        height: 800,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ResponsiveBuilder(
            builder: (context, constraints) {
              return EmojiPicker(folderID: folderID, parentID: parentID);
            },
          ),
        ),
      ),
    );
  }
}
