// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    // Use Roboto font instead of tester's default Ahem font
    final _fontLoader = FontLoader('Regular')
      ..addFont(rootBundle.load('assets/fonts/Roboto/Regular.ttf'));
    await _fontLoader.load();

    return pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
  }
}
