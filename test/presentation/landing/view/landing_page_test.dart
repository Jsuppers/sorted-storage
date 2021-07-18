// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/presentation/about/view/about_page.dart';
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/landing/components/landing_fab_extender.dart';
import 'package:sorted_storage/presentation/landing/view/landing_page.dart';
import 'package:sorted_storage/presentation/profile/view/profile_page.dart';
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

  group('Landing Page', () {
    testWidgets('renders landing page', (tester) async {
      when(() => _landingNavigationBloc.state)
          .thenReturn(const LandingNavigationPageChangeSuccess(0));
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: const LandingPage(),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    group('Floating Action Button', () {
      testWidgets(
          'adds LandingNavigationPageChangeSuccess when '
          'floating action button when tapped', (tester) async {
        when(() => _landingNavigationBloc.state)
            .thenReturn(const LandingNavigationPageChangeSuccess(0));
        await tester.pumpApp(
          BlocProvider.value(
            value: _landingNavigationBloc,
            child: const LandingPage(),
          ),
        );

        await tester
            .tap(find.byKey(const Key('landing_page_floating_action_button')));

        verify(() => _landingNavigationBloc.add(
            const LandingNavigationFloatingActionButtonPressed())).called(1);
      });

      testWidgets('toggles floating action button when tapped', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: LandingNavigationBloc(),
            child: const LandingPage(),
          ),
        );

        await tester
            .tap(find.byKey(const Key('landing_page_floating_action_button')));
        await tester.pump();
        expect(find.byType(LandingFabExtender), findsOneWidget);

        await tester
            .tap(find.byKey(const Key('landing_page_floating_action_button')));
        await tester.pump();
        expect(find.byType(LandingFabExtender), findsNothing);
      });
    });

    group('renders the correct pages depending on the state', () {
      testWidgets('renders profile page', (tester) async {
        when(() => _landingNavigationBloc.state)
            .thenReturn(const LandingNavigationPageChangeSuccess(1));
        await tester.pumpApp(
          BlocProvider.value(
            value: _landingNavigationBloc,
            child: const ProfilePage(),
          ),
        );
        expect(find.byType(ProfilePage), findsOneWidget);
      });

      testWidgets('renders about page', (tester) async {
        when(() => _landingNavigationBloc.state)
            .thenReturn(const LandingNavigationPageChangeSuccess(2));
        await tester.pumpApp(
          BlocProvider.value(
            value: _landingNavigationBloc,
            child: const AboutPage(),
          ),
        );
        expect(find.byType(AboutPage), findsOneWidget);
      });
    });
  });
}
