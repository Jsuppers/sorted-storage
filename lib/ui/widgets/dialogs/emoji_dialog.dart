// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/models/folder_content.dart';
import 'package:web/ui/widgets/edit/emoji_picker.dart';

/// emoji dialog
class EmojiDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const EmojiDialog({ Key? key, this.folder}) : super(key: key);

  // ignore: public_member_api_docs
  final FolderContent? folder;

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
              return EmojiPicker(
                  folder: folder);
            },
          ),
        ),
      ),
    );
  }
}
