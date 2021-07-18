// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/landing/components/components.dart';
import '../../../helpers/helpers.dart';

class MockLandingNavigationBloc
    extends MockBloc<LandingNavigationEvent, LandingNavigationState>
    implements LandingNavigationBloc {}

class LandingNavigationEventFake extends Fake
    implements LandingNavigationEvent {}

void main() {
  late LandingNavigationBloc _landingNavigationBloc;

  setUpAll(() {
    registerFallbackValue(LandingNavigationEventFake());
    registerFallbackValue(const LandingNavigationPageChangeSuccess(0));
  });

  setUp(() {
    _landingNavigationBloc = MockLandingNavigationBloc();
  });

  group('Landing Fab Extender', () {
    testWidgets('renders home, profile, donate buttons', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: Stack(children: const [LandingFabExtender()]),
        ),
      );
      expect(find.byKey(const Key('landing_fab_extender_profile_button')),
          findsOneWidget);
      expect(find.byKey(const Key('landing_fab_extender_profile_button')),
          findsOneWidget);
      expect(find.byKey(const Key('landing_fab_extender_home_button')),
          findsOneWidget);
    });

    testWidgets(
        'adds LandingNavigationHomeButtonPressed when '
        'home button is tapped', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: Stack(children: const [LandingFabExtender()]),
        ),
      );
      await tester
          .tap(find.byKey(const Key('landing_fab_extender_home_button')));
      verify(() => _landingNavigationBloc
          .add(const LandingNavigationHomeButtonPressed())).called(1);
    });

    testWidgets(
        'adds LandingNavigationProfileButtonPressed when '
        'profile button is tapped', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: Stack(children: const [LandingFabExtender()]),
        ),
      );
      await tester
          .tap(find.byKey(const Key('landing_fab_extender_profile_button')));
      verify(() => _landingNavigationBloc
          .add(const LandingNavigationProfileButtonPressed())).called(1);
    });

    testWidgets(
        'adds LandingNavigationDonateButtonPressed when '
        'donate button is tapped', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: Stack(children: const [LandingFabExtender()]),
        ),
      );
      await tester
          .tap(find.byKey(const Key('landing_fab_extender_donate_button')));
      verify(() => _landingNavigationBloc
          .add(const LandingNavigationDonateButtonPressed())).called(1);
    });
  });
}
