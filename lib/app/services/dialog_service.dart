import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/ui/widgets/dialogs/cookie_dialog.dart';
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
      {String folderID, String parentID}) {
    FilePicker.platform
        .pickFiles(
            type: FileType.media, allowMultiple: true, withReadStream: true)
        .then((file) => {
              if (file != null && file.files != null && file.files.isNotEmpty)
                {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (BuildContext context) {
                      return ImageUploadDialog(
                        file: file,
                          folderID: folderID, parentID: parentID);
                    },
                  )
                }
            });
  }

  /// dialog to share a folder
  static void editDialog(BuildContext context, String folderID) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EditStoryDialog(folderID: folderID);
      },
    );
  }

  /// dialog to share a folder
  static void shareDialog(
      BuildContext context, String folderID, String commentsID) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ShareDialog(commentsID: commentsID, folderID: folderID);
      },
    );
  }

  /// dialog to allow the user to select a emoji
  static void emojiDialog(BuildContext context,
      {String folderID, String parentID, StoryMetadata metadata}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EmojiDialog(
            folderID: folderID, parentID: parentID, metadata: metadata);
      },
    );
  }

  /// dialog to show error messages when syncing
  static void errorSyncingDialog(BuildContext context,
      {List<String> errorMessages}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ErrorDialog(errorMessages: errorMessages);
      },
    );
  }
}
