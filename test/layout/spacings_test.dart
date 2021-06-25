// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';

void main() {
  test('spacings change depending on scale factor', () {
    const _scaleFactor = ScreenScaleFactors.smallScaleFactor;
    AppSpacings.scaleFactor = _scaleFactor;
    expect(AppSpacings.four, 4 * _scaleFactor);
    expect(AppSpacings.six, 6 * _scaleFactor);
    expect(AppSpacings.eight, 8 * _scaleFactor);
    expect(AppSpacings.twelve, 12 * _scaleFactor);
    expect(AppSpacings.fourteen, 14 * _scaleFactor);
    expect(AppSpacings.sixteen, 16 * _scaleFactor);
    expect(AppSpacings.eighteen, 18 * _scaleFactor);
    expect(AppSpacings.twentyFour, 24 * _scaleFactor);
    expect(AppSpacings.thirtyTwo, 32 * _scaleFactor);
    expect(AppSpacings.fortyEight, 48 * _scaleFactor);
  });
}
