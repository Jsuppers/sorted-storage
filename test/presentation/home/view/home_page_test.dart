// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import '../../../helpers/helpers.dart';

class MockLandingNavigationBloc
    extends MockBloc<LandingNavigationEvent, LandingNavigationState>
    implements LandingNavigationBloc {}

class LandingNavigationEventFake extends Fake
    implements LandingNavigationEvent {}

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late MockAuthenticationRepository _authenticationRepository;
  late LandingNavigationBloc _landingNavigationBloc;

  setUpAll(() {
    registerFallbackValue(LandingNavigationEventFake());
    registerFallbackValue(const LandingNavigationPageChangeSuccess(0));
  });

  setUp(() {
    _landingNavigationBloc = MockLandingNavigationBloc();
    _authenticationRepository = MockAuthenticationRepository();
  });

  group('Home Page', () {
    testWidgets('renders Home Page', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: const HomePage(),
        ),
        authenticationRepository: _authenticationRepository,
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets(
        'adds LandingNavigationAboutButtonPressed when about button is tapped',
        (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: _landingNavigationBloc,
          child: const HomePage(),
        ),
        authenticationRepository: _authenticationRepository,
      );

      await tester.tap(find.byKey(const Key('home_page_about_button')));
      verify(() => _landingNavigationBloc
          .add(const LandingNavigationAboutButtonPressed())).called(1);
    });
  });
}
