// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';

void main() {
  late LandingNavigationBloc _landingNavigationBloc;

  setUp(() {
    _landingNavigationBloc = LandingNavigationBloc();
  });

  group('LandingBloc', () {
    test('initial state is page 0', () {
      expect(_landingNavigationBloc.state,
          const LandingNavigationPageChangeSuccess(0));
    });

    group('Floating Action Button', () {
      blocTest(
        'emits updated state',
        build: () => _landingNavigationBloc,
        act: (LandingNavigationBloc bloc) =>
            bloc.add(const LandingNavigationFloatingActionButtonPressed()),
        expect: () =>
            [isA<LandingNavigationFloatingActionButtonToggledInProgress>()],
      );
    });

    group('Page Selection', () {
      blocTest(
        'emits state with page 0 when home button is tapped',
        build: () => _landingNavigationBloc,
        act: (LandingNavigationBloc bloc) =>
            bloc.add(const LandingNavigationHomeButtonPressed()),
        expect: () => [const LandingNavigationPageChangeSuccess(0)],
      );

      blocTest(
        'emits state with page 1 if profile button is tapped',
        build: () => _landingNavigationBloc,
        act: (LandingNavigationBloc bloc) =>
            bloc.add(const LandingNavigationProfileButtonPressed()),
        expect: () => [const LandingNavigationPageChangeSuccess(1)],
      );

      blocTest(
        'emits state with page 2 if about button is tapped',
        build: () => _landingNavigationBloc,
        act: (LandingNavigationBloc bloc) =>
            bloc.add(const LandingNavigationAboutButtonPressed()),
        expect: () => [const LandingNavigationPageChangeSuccess(2)],
      );
    });

    group('Donation Button', () {
      blocTest(
        'emits state when donation button is tapped',
        build: () => _landingNavigationBloc,
        act: (LandingNavigationBloc bloc) =>
            bloc.add(const LandingNavigationDonateButtonPressed()),
        expect: () => [const LandingNavigationOpenDonationPageInProgress()],
      );
    });
  });
}
