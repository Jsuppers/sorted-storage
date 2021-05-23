// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/models/folder.dart';
import 'package:web/ui/widgets/edit/edit_folder.dart';

/// emoji dialog
class EditFolderDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const EditFolderDialog({Key? key, this.folder, this.parent})
      : super(key: key);

  // ignore: public_member_api_docs
  final Folder? folder;
  final Folder? parent;

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
