// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';

void main() {
  test('sets screen size', () {
    DeviceScreenSize.screenSize = ScreenSize.small;
    expect(DeviceScreenSize.screenSize, ScreenSize.small);
  });
}
