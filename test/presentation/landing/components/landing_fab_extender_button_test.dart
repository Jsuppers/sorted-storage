import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group('Landing FAB Extender Button', () {
    testWidgets('renders button', (tester) async {
      await tester.pumpApp(LandingFabExtenderButton(
        icon: const Icon(Icons.ac_unit),
        title: 'Title',
        color: Colors.red,
        onTap: () => null,
      ));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('adds an event when button is tapped', (tester) async {
      await tester.pumpApp(LandingFabExtenderButton(
        icon: const Icon(Icons.ac_unit),
        title: 'Title',
        color: Colors.red,
        onTap: () => _landingNavigationBloc
            .add(const LandingNavigationAboutButtonPressed()),
      ));

      await tester.tap(find.byType(LandingFabExtenderButton));
      verify(() => _landingNavigationBloc
          .add(const LandingNavigationAboutButtonPressed())).called(1);
    });
  });
}
