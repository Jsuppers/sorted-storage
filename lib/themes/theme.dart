// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:sorted_storage/themes/colors.dart';

class StorageTheme {
  StorageTheme({Box? themeBox}) : _themeBox = themeBox ?? Hive.box('themes');

  final Box _themeBox;

  ThemeData light({required TextTheme textTheme}) {
    return ThemeData.light().copyWith(
      appBarTheme: _appBarTheme,
      textTheme: textTheme.apply(
        bodyColor: StorageColors.black,
        displayColor: StorageColors.black,
      ),
    );
  }

  ThemeData dark({required TextTheme textTheme}) {
    return ThemeData.dark().copyWith(
      appBarTheme: _appBarTheme,
      textTheme: textTheme.apply(
        bodyColor: StorageColors.white,
        displayColor: StorageColors.white,
      ),
      scaffoldBackgroundColor: StorageColors.grey,
    );
  }

  ThemeMode get themeMode {
    final _themeModeValue = _themeBox.get('themeMode', defaultValue: 0);
    return mapValueToThemeMode(_themeModeValue);
  }

  set themeMode(ThemeMode mode) {
    _themeBox.put('themeMode', mapThemeModeToValue(mode));
  }

  ThemeMode mapValueToThemeMode(int themeModeValue) {
    switch (themeModeValue) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  int mapThemeModeToValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

  AppBarTheme get _appBarTheme {
    return const AppBarTheme(color: StorageColors.blue);
  }
}
