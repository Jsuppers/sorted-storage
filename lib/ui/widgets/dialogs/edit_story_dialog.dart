// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/models/folder_content.dart';

// Project imports:
import 'package:web/ui/widgets/edit/edit_folder.dart';

/// emoji dialog
class EditStoryDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const EditStoryDialog({Key? key, this.folder, this.parent})
      : super(key: key);

  // ignore: public_member_api_docs
  final FolderContent? folder;
  final FolderContent? parent;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ResponsiveBuilder(
          builder: (BuildContext context, SizingInformation constraints) {
            return EditFolder(folder: folder, parent: parent);
          },
        ),
      ),
    );
  }
}
