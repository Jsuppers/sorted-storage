import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/ui/widgets/dialogs/cookie_dialog.dart';
import 'package:web/ui/widgets/dialogs/edit_folder_dialog.dart';
import 'package:web/ui/widgets/dialogs/edit_story_dialog.dart';
import 'package:web/ui/widgets/dialogs/emoji_dialog.dart';
import 'package:web/ui/widgets/dialogs/error_dialog.dart';
import 'package:web/ui/widgets/dialogs/image_upload_dialog.dart';
import 'package:web/ui/widgets/dialogs/share_dialog.dart';

/// Service to open dialogs
class DialogService {
  /// cookie dialog, which the user needs to accept
  static void cookieDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return CookieDialog();
      },
    );
  }

  static void imageUploadDialog(BuildContext context,
      {required String folderID, required String parentID}) {
    FilePicker.platform
        .pickFiles(
            type: FileType.media, allowMultiple: true, withReadStream: true)
        .then((FilePickerResult? file) => {
              if (file != null && file.files != null && file.files.isNotEmpty)
                {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (BuildContext context) {
                      return ImageUploadDialog(
                          file: file, folderID: folderID, parentID: parentID);
                    },
                  )
                }
            });
  }

  /// dialog to share a folder
  static void editDialog(BuildContext context,
      {String? folderID, String? parentID}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EditStoryDialog(folderID: folderID, parentID: parentID);
      },
    ).then((_) =>
        // update the ui with any changes made in the edit dialog
        BlocProvider.of<CloudStoriesBloc>(context)
            .add(const CloudStoriesEvent(CloudStoriesType.refresh)));
  }

  /// dialog to share a folder
  static void editFolderDialog(BuildContext context,
      {FolderProperties? folder}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EditFolderDialog(folder: folder);
      },
    ).then((_) =>
        // update the ui with any changes made in the edit dialog
        BlocProvider.of<CloudStoriesBloc>(context)
            .add(const CloudStoriesEvent(CloudStoriesType.retrieveFolders)));
  }

  /// dialog to share a folder
  static void shareDialog(BuildContext context, String folderID) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ShareDialog(folderID: folderID);
      },
    );
  }

  /// dialog to allow the user to select a emoji
  static void emojiDialog(BuildContext context,
      {required String folderID,
      String? parentID,
      StoryMetadata? metadata,
      FolderProperties? folder}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EmojiDialog(
            folderID: folderID,
            parentID: parentID,
            metadata: metadata,
            folder: folder);
      },
    );
  }

  /// dialog to show error messages when syncing
  static void errorSyncingDialog(BuildContext context,
      {required List<String> errorMessages}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ErrorDialog(errorMessages: errorMessages);
      },
    );
  }

  static showAlertDialog(BuildContext context,
      {required String message, required Function callback}) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () {
        Navigator.of(context).pop();
        callback();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
