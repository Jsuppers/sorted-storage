// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';

extension RecipeWidgetTester on WidgetTester {
  void setDisplaySize(Size size) {
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
  }

  /// Sets display size to small, similar to a phone's display size.
  void setSmallDisplaySize({Orientation? orientation}) {
    const _portraitSize = Size(ScreenBreakpoints.small - 1, 1000);
    const _landscapeSize = Size(1000, ScreenBreakpoints.small - 1);
    setDisplaySize(
      orientation == Orientation.landscape ? _landscapeSize : _portraitSize,
    );
  }

  /// Sets display size to small, similar to a tablet's display size.
  void setMediumDisplaySize({Orientation? orientation}) {
    const _portraitSize = Size(800, ScreenBreakpoints.medium - 1);
    const _landscapeSize = Size(ScreenBreakpoints.medium - 1, 800);
    setDisplaySize(
      orientation == Orientation.portrait ? _portraitSize : _landscapeSize,
    );
  }

  /// Sets display size to large, similar to a desktop's display size.
  void setLargeDisplaySize({Orientation? orientation}) {
    const _portraitSize = Size(1500, ScreenBreakpoints.large - 1);
    const _landscapeSize = Size(ScreenBreakpoints.large - 1, 1500);
    setDisplaySize(
      orientation == Orientation.portrait ? _portraitSize : _landscapeSize,
    );
  }

  /// Sets display size to xLarge, similar to a large desktop's display size.
  void setXLargeDisplaySize({Orientation? orientation}) {
    const _portraitSize = Size(2000, 4000);
    const _landscapeSize = Size(4000, 2000);
    setDisplaySize(
      orientation == Orientation.portrait ? _portraitSize : _landscapeSize,
    );
  }
}
