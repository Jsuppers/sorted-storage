// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/components/landing_fab_extender.dart';

class LandingFabRepository {
  final _overlayEntry = OverlayEntry(
    builder: (context) {
      return const LandingFabExtender();
    },
  );

  void toggleButton(BuildContext context) {
    final _overlayState = Overlay.of(context);

    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    } else {
      _overlayState?.insert(_overlayEntry);
    }
  }

  void hideButtons() {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  }
}
