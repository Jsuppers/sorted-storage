import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/ui/widgets/emoji_picker.dart';

/// emoji dialog
class EmojiDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const EmojiDialog({Key key, this.parentID, this.folderID}) : super(key: key);

  // ignore: public_member_api_docs
  final String parentID;

  // ignore: public_member_api_docs
  final String folderID;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: SizedBox(
        height: 800,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ResponsiveBuilder(
            builder: (BuildContext context, SizingInformation constraints) {
              return EmojiPicker(folderID: folderID, parentID: parentID);
            },
          ),
        ),
      ),
    );
  }
}
