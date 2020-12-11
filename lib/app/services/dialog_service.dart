import 'package:flutter/material.dart';
import 'package:web/ui/widgets/dialogs/cookie_dialog.dart';
import 'package:web/ui/widgets/dialogs/emoji_dialog.dart';
import 'package:web/ui/widgets/dialogs/share_dialog.dart';

class DialogService {
  static cookieDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return CookieDialog();
      },
    );
  }

  static shareDialog(BuildContext context, String folderID, String commentsID) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ShareDialog(commentsID: commentsID, folderID: folderID);
      },
    );
  }

  static emojiDialog(BuildContext context, {String folderID, String parentID}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return EmojiDialog(folderID: folderID, parentID: parentID);
      },
    );
  }
}
