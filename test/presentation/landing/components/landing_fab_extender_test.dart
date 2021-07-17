import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorted_storage/presentation/landing/components/components.dart';
import '../../../helpers/helpers.dart';

void main() {
  group('Landing Fab Extender', () {
    testWidgets('renders home, profile, donate buttons', (tester) async {
      await tester.pumpApp(Stack(children: const [LandingFabExtender()]));
      expect(find.byKey(const Key('landing_fab_extender_profile_button')),
          findsOneWidget);
      expect(find.byKey(const Key('landing_fab_extender_profile_button')),
          findsOneWidget);
      expect(find.byKey(const Key('landing_fab_extender_home_button')),
          findsOneWidget);
    });
  });
}
