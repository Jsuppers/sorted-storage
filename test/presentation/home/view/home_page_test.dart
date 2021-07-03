// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import '../../../helpers/helpers.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late MockAuthenticationRepository _authenticationRepository;

  setUp(() {
    _authenticationRepository = MockAuthenticationRepository();
  });

  testWidgets('renders Home Page', (tester) async {
    await tester.pumpApp(
      const HomePage(),
      authenticationRepository: _authenticationRepository,
    );

    expect(find.byType(CustomScrollView), findsOneWidget);
  });
}
