import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorted_storage/widgets/helpers/remove_scroll_glow.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  test('removes scroll glow', () {
    final BuildContext _context = MockBuildContext();
    const _child = SizedBox();
    const _axisDirection = AxisDirection.down;
    expect(
      const RemoveScrollGlow()
          .buildViewportChrome(_context, _child, _axisDirection),
      _child,
    );
  });
}
