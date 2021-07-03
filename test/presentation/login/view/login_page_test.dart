// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/presentation/login/components/components.dart';
import 'package:sorted_storage/presentation/login/view/login_page.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import '../../../helpers/helpers.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late MockAuthenticationRepository _authenticationRepository;

  setUp(() {
    _authenticationRepository = MockAuthenticationRepository();
  });

  testWidgets('renders background', (tester) async {
    await tester.pumpApp(
      const LoginPage(),
      authenticationRepository: _authenticationRepository,
    );
    expect(find.byKey(const Key('login_page_background')), findsOneWidget);
  });

  testWidgets('renders logo', (tester) async {
    await tester.pumpApp(
      const LoginPage(),
      authenticationRepository: _authenticationRepository,
    );
    expect(find.byKey(const Key('login_page_logo')), findsOneWidget);
  });

  testWidgets('renders sign in with google button', (tester) async {
    await tester.pumpApp(
      const LoginPage(),
      authenticationRepository: _authenticationRepository,
    );
    expect(find.byType(GoogleAuthButton), findsOneWidget);
  });

  testWidgets(
      'renders links pointing to terms and conditions and privacy policy',
      (tester) async {
    await tester.pumpApp(
      const LoginPage(),
      authenticationRepository: _authenticationRepository,
    );
    expect(
      find.byKey(const Key('login_page_legal_consents_row')),
      findsOneWidget,
    );
  });

  testWidgets('tapping on googleAuthButton signs in with google',
      (tester) async {
    when(() => _authenticationRepository.signInWithGoogle())
        .thenAnswer((_) async => {});

    await tester.pumpApp(
      const LoginPage(),
      authenticationRepository: _authenticationRepository,
    );

    await tester.tap(find.byType(GoogleAuthButton));

    verify(() => _authenticationRepository.signInWithGoogle()).called(1);
  });
}
