import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/ui/widgets/edit/edit_story.dart';

/// emoji dialog
class EditStoryDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const EditStoryDialog({Key? key, this.folderID, this.parentID})
      : super(key: key);

  // ignore: public_member_api_docs
  final String? folderID;
  final String? parentID;

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
            return EditStory(folderID, parentID: parentID);
          },
        ),
      ),
    );
  }
}
