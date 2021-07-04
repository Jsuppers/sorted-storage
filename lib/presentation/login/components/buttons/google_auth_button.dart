// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/themes/themes.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({Key? key, required this.onPressed}) : super(key: key);

  static const _darkBackgroundColor = Color(0xFF4285F4);
  static const _darkTextColor = Color(0xCC000000);

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return RawMaterialButton(
      clipBehavior: Clip.antiAlias,
      fillColor: _isDarkMode ? _darkBackgroundColor : StorageColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      elevation: 1,
      highlightElevation: 0,
      onPressed: onPressed,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ink(
              color:
                  _isDarkMode ? StorageColors.white : StorageColors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/google.png',
                  height: 18,
                  width: 18,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Text(
              'Sign in with Google',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: StorageFontWeight.medium,
                fontSize: 14,
                color: _isDarkMode ? StorageColors.white : _darkTextColor,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
