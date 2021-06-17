// Flutter imports:
import 'package:flutter/material.dart';

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
