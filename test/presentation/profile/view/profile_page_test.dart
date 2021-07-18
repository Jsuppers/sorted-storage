// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

// Project imports:
import 'package:sorted_storage/constants/user_constants.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/profile/bloc/profile_bloc.dart';
import 'package:sorted_storage/presentation/profile/components/profile_dialog.dart';
import 'package:sorted_storage/presentation/profile/view/profile_page.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import '../../../helpers/helpers.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockLandingNavigationBloc
    extends MockBloc<LandingNavigationEvent, LandingNavigationState>
    implements LandingNavigationBloc {}

class LandingNavigationEventFake extends Fake
    implements LandingNavigationEvent {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class ProfileEventFake extends Fake implements ProfileEvent {}

void main() {
  late AuthenticationRepository _authenticationRepository;

  setUp(() {
    _authenticationRepository = MockAuthenticationRepository();
  });

  group('Profile Page', () {
    testWidgets('renders profile page', (tester) async {
      when(() => _authenticationRepository.username)
          .thenReturn(UserConstants.username);
      when(() => _authenticationRepository.email)
          .thenReturn(UserConstants.email);
      when(() => _authenticationRepository.photoUrl)
          .thenReturn(UserConstants.imageLink);

      await mockNetworkImages(() async {
        await tester.pumpApp(
          const ProfilePage(),
          authenticationRepository: _authenticationRepository,
        );

        await tester.pump();

        expect(find.byType(ProfileView), findsOneWidget);
      });
    });
  });

  group('Profile View', () {
    late LandingNavigationBloc _landingNavigationBloc;
    late ProfileBloc _profileBloc;

    setUpAll(() {
      registerFallbackValue(LandingNavigationEventFake());
      registerFallbackValue(const LandingNavigationPageChangeSuccess(0));
      registerFallbackValue(ProfileEventFake());
      registerFallbackValue(const ProfileInitial());
    });

    setUp(() {
      _landingNavigationBloc = MockLandingNavigationBloc();
      _profileBloc = MockProfileBloc();
    });

    group('Profile Dialog', () {
      setUp(() {
        when(() => _authenticationRepository.username)
            .thenReturn(UserConstants.username);
        when(() => _authenticationRepository.email)
            .thenReturn(UserConstants.email);
        when(() => _authenticationRepository.photoUrl)
            .thenReturn(UserConstants.imageLink);
        whenListen(
          _profileBloc,
          Stream.fromIterable(
            const [
              ProfileInitial(),
              ProfileDialogShowedSuccess(),
            ],
          ),
          initialState: const ProfileInitial(),
        );
      });

      testWidgets('shows profileDialog when profile view is rendered',
          (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpApp(
            MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _landingNavigationBloc),
                BlocProvider.value(value: _profileBloc),
              ],
              child: const ProfileView(),
            ),
            authenticationRepository: _authenticationRepository,
          );

          await tester.pumpAndSettle();

          expect(find.byType(ProfileDialog), findsOneWidget);
        });
      });

      testWidgets(
          'ProfileCloseButtonPressed is called '
          'when close button is tapped', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpApp(
            MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _landingNavigationBloc),
                BlocProvider.value(value: _profileBloc),
              ],
              child: const ProfileView(),
            ),
            authenticationRepository: _authenticationRepository,
          );

          await tester.pump();

          await tester
              .tap(find.byKey(const Key('profile_dialog_close_button')));
          verify(() => _profileBloc.add(const ProfileCloseButtonPressed()))
              .called(1);
        });
      });

      testWidgets(
          'ProfileLogoutButtonPressed is called '
          'when close button is tapped', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpApp(
            MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _landingNavigationBloc),
                BlocProvider.value(value: _profileBloc),
              ],
              child: const ProfileView(),
            ),
            authenticationRepository: _authenticationRepository,
          );

          await tester.pump();

          await tester
              .tap(find.byKey(const Key('profile_dialog_logout_button')));
          verify(() => _profileBloc.add(const ProfileLogoutButtonPressed()))
              .called(1);
        });
      });
    });

    testWidgets(
        'LandingNavigationProfileBackButtonPressed is called '
        'when back button is tapped', (tester) async {
      when(() => _profileBloc.state).thenReturn(const ProfileInitial());
      when(() => _profileBloc.add(const ProfileDialogShowed()))
          .thenAnswer((_) {});

      await mockNetworkImages(() async {
        await tester.pumpApp(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _landingNavigationBloc),
              BlocProvider.value(value: _profileBloc),
            ],
            child: const ProfileView(),
          ),
          authenticationRepository: _authenticationRepository,
        );

        await tester.pump();

        await tester.tap(find.byKey(const Key('profile_view_back_button')));
        verify(() => _landingNavigationBloc
            .add(const LandingNavigationProfileBackButtonPressed())).called(1);
      });
    });
  });
}
