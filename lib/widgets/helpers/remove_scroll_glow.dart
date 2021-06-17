// Flutter imports:
import 'package:flutter/material.dart';

/// Removes scroll glow effect found in scrollable lists
class RemoveScrollGlow extends ScrollBehavior {
  const RemoveScrollGlow();

  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
