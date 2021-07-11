import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required Widget child,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: child,
      );
    },
  );
}
