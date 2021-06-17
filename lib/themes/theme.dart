// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:sorted_storage/themes/colors.dart';

abstract class StorageTheme {
  static final _box = Hive.box('themes');

  static ThemeData light({required TextTheme textTheme}) {
    return ThemeData.light().copyWith(
      appBarTheme: _appBarTheme,
      textTheme: textTheme.apply(
        bodyColor: StorageColors.black,
        displayColor: StorageColors.black,
      ),
    );
  }

  static ThemeData dark({required TextTheme textTheme}) {
    return ThemeData.dark().copyWith(
      appBarTheme: _appBarTheme,
      textTheme: textTheme.apply(
        bodyColor: StorageColors.white,
        displayColor: StorageColors.white,
      ),
      scaffoldBackgroundColor: StorageColors.grey,
    );
  }

  static ThemeMode get themeMode {
    final _themeModeValue = _box.get('themeMode', defaultValue: 0);
    switch (_themeModeValue) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  static set themeMode(ThemeMode mode) {
    late final int _themeModeValue;

    switch (mode) {
      case ThemeMode.system:
        _themeModeValue = 0;
        break;
      case ThemeMode.light:
        _themeModeValue = 1;
        break;
      case ThemeMode.dark:
        _themeModeValue = 2;
        break;
    }

    _box.put('themeMode', _themeModeValue);
  }

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(color: StorageColors.blue);
  }
}
