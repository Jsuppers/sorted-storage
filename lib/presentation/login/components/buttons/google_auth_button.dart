// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({Key? key}) : super(key: key);

  static const _darkBackgroundColor = Color(0xFF4285F4);
  static const _darkTextColor = Color(0xCC000000);

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return RawMaterialButton(
      clipBehavior: Clip.hardEdge,
      fillColor: _isDarkMode ? _darkBackgroundColor : StorageColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      elevation: 1,
      highlightElevation: 0,
      onPressed: () =>
          context.read<AuthenticationRepository>().signInWithGoogle(),
      child: SizedBox(
        height: 40,
        width: 200,
        child: Row(
          children: [
            const SizedBox(width: 6),
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
            const Spacer(),
            Text(
              'Sign in with Google',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: StorageFontWeight.medium,
                fontSize: 14,
                color: _isDarkMode ? StorageColors.white : _darkTextColor,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
