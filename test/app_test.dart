// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/app/app.dart';
import 'package:sorted_storage/presentation/login/view/login_page.dart';
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/themes/typography/typography.dart';
import 'package:sorted_storage/utils/services/authentication/repositories/authentication_repository.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';
import 'helpers/helpers.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late AuthenticationRepository _authenticationRepository;
  setUpAll(() async {
    // Initialize hive
    await Hive.initFlutter();
    await Hive.openBox('themes');

    // Use Roboto font instead of tester's default Ahem font
    final _fontLoader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto/Regular.ttf'));
    await _fontLoader.load();

    _authenticationRepository = MockAuthenticationRepository();
    when(() => _authenticationRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
  });

  group('App', () {
    testWidgets('renders LoginPage', (tester) async {
      await tester
          .pumpWidget(App(authenticationRepository: _authenticationRepository));

      expect(find.byType(ResponsiveLayoutBuilder), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('uses small theme on small devices', (tester) async {
      tester.setSmallDisplaySize();

      await tester
          .pumpWidget(App(authenticationRepository: _authenticationRepository));

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme().light(textTheme: StorageTextTheme.smallTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme().dark(textTheme: StorageTextTheme.smallTextTheme),
      );
    });

    testWidgets('uses medium theme on small devices', (tester) async {
      tester.setMediumDisplaySize();

      await tester
          .pumpWidget(App(authenticationRepository: _authenticationRepository));

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme().light(textTheme: StorageTextTheme.mediumTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme().dark(textTheme: StorageTextTheme.mediumTextTheme),
      );
    });

    testWidgets('uses large theme on small devices', (tester) async {
      tester.setLargeDisplaySize();

      await tester
          .pumpWidget(App(authenticationRepository: _authenticationRepository));

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme().light(textTheme: StorageTextTheme.largeTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme().dark(textTheme: StorageTextTheme.largeTextTheme),
      );
    });

    testWidgets('uses xLarge theme on small devices', (tester) async {
      tester.setXLargeDisplaySize();

      await tester
          .pumpWidget(App(authenticationRepository: _authenticationRepository));

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme().light(textTheme: StorageTextTheme.xLargeTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme().dark(textTheme: StorageTextTheme.xLargeTextTheme),
      );
    });
  });
}
