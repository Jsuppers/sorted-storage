// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/ui/widgets/dialogs/cookie_dialog.dart';
import 'package:web/ui/widgets/dialogs/edit_folder_dialog.dart';
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
      {required Folder folder}) {
    final FolderStorageBloc cloudBloc =
        BlocProvider.of<FolderStorageBloc>(context);
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
                      return ImageUploadDialog(file: file, folder: folder);
                    },
                  ).then((value) => cloudBloc.add(FolderStorageEvent(
                      FolderStorageType.refresh,
                      folderID: folder.parent!.id)))
                }
            });
  }

  /// dialog to share a folder
  static void editDialog(BuildContext context,
      {Folder? folder, Folder? parent}) {
    final FolderStorageBloc cloudBloc =
        BlocProvider.of<FolderStorageBloc>(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EditFolderDialog(folder: folder, parent: parent);
      },
    ).then((_) {
      // update the ui with any changes made in the edit dialog
      cloudBloc.add(FolderStorageEvent(FolderStorageType.refresh,
          folderID: parent?.id, data: folder));
    });
  }

  /// dialog to share a folder
  static void shareDialog(BuildContext context, Folder folder) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ShareDialog(folder: folder);
      },
    );
  }

  /// dialog to allow the user to select a emoji
  static void emojiDialog(BuildContext context, {Folder? folder}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EmojiDialog(folder: folder);
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
