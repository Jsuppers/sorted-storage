// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:sorted_storage/themes/theme.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit() : super(StorageTheme().themeMode);

  void toggleTheme(ThemeMode themeMode) {
    StorageTheme().themeMode = themeMode;
    emit(themeMode);
  }
}
