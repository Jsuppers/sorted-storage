import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorted_storage/themes/themes.dart';

class MockHiveBox extends Mock implements Box {}

void main() {
  group('Themes', () {
    late Box _box;
    late StorageTheme _storageTheme;
    const _textTheme = TextTheme();
    const _appBarTheme = AppBarTheme(color: StorageColors.blue);

    setUp(() {
      _box = MockHiveBox();
      _storageTheme = StorageTheme(themeBox: _box);
    });

    test('returns the correct light theme', () {
      expect(
          _storageTheme.light(textTheme: _textTheme),
          ThemeData.light().copyWith(
            appBarTheme: _appBarTheme,
            textTheme: _textTheme.apply(
              bodyColor: StorageColors.black,
              displayColor: StorageColors.black,
            ),
          ));
    });

    test('returns the correct dark theme', () {
      expect(
          _storageTheme.dark(textTheme: _textTheme),
          ThemeData.dark().copyWith(
            appBarTheme: _appBarTheme,
            textTheme: _textTheme.apply(
              bodyColor: StorageColors.white,
              displayColor: StorageColors.white,
            ),
            scaffoldBackgroundColor: StorageColors.grey,
          ));
    });

    test('returns the correct themeMode', () {
      when(() => _box.get('themeMode', defaultValue: 0)).thenReturn(0);
      expect(_storageTheme.themeMode, ThemeMode.system);

      when(() => _box.get('themeMode', defaultValue: 0)).thenReturn(1);
      expect(_storageTheme.themeMode, ThemeMode.light);

      when(() => _box.get('themeMode', defaultValue: 0)).thenReturn(2);
      expect(_storageTheme.themeMode, ThemeMode.dark);
    });

    test('sets the correct themeMode', () {
      when(() => _box.put('themeMode', 0)).thenAnswer((_) async {});
      _storageTheme.themeMode = ThemeMode.system;
      verify(() => _box.put('themeMode', 0)).called(1);

      when(() => _box.put('themeMode', 1)).thenAnswer((_) async {});
      _storageTheme.themeMode = ThemeMode.light;
      verify(() => _box.put('themeMode', 1)).called(1);

      when(() => _box.put('themeMode', 2)).thenAnswer((_) async {});
      _storageTheme.themeMode = ThemeMode.dark;
      verify(() => _box.put('themeMode', 2)).called(1);
    });

    test('maps value to themeMode', () {
      expect(_storageTheme.mapValueToThemeMode(0), ThemeMode.system);
      expect(_storageTheme.mapValueToThemeMode(1), ThemeMode.light);
      expect(_storageTheme.mapValueToThemeMode(2), ThemeMode.dark);
    });

    test('maps themeMode to value', () {
      expect(_storageTheme.mapThemeModeToValue(ThemeMode.system), 0);
      expect(_storageTheme.mapThemeModeToValue(ThemeMode.light), 1);
      expect(_storageTheme.mapThemeModeToValue(ThemeMode.dark), 2);
    });
  });
}
