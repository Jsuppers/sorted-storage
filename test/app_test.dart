// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/app/app.dart';
import 'package:sorted_storage/presentation/landing/view/lading_page.dart';
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/themes/typography/typography.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';
import 'helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('renders LandingPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(LandingPage), findsOneWidget);
    });
  });

  group('App', () {
    testWidgets('uses small theme on small devices', (tester) async {
      tester.setSmallDisplaySize();

      await tester.pumpWidget(const App());

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme.light(textTheme: StorageTextTheme.smallTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme.dark(textTheme: StorageTextTheme.smallTextTheme),
      );
    });

    testWidgets('uses medium theme on small devices', (tester) async {
      tester.setMediumDisplaySize();

      await tester.pumpWidget(const App());

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme.light(textTheme: StorageTextTheme.mediumTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme.dark(textTheme: StorageTextTheme.mediumTextTheme),
      );
    });

    testWidgets('uses large theme on small devices', (tester) async {
      tester.setLargeDisplaySize();

      await tester.pumpWidget(const App());

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme.light(textTheme: StorageTextTheme.largeTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme.dark(textTheme: StorageTextTheme.largeTextTheme),
      );
    });

    testWidgets('uses xLarge theme on small devices', (tester) async {
      tester.setXLargeDisplaySize();

      await tester.pumpWidget(const App());

      final _materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        _materialApp.theme,
        StorageTheme.light(textTheme: StorageTextTheme.xLargeTextTheme),
      );

      expect(
        _materialApp.darkTheme,
        StorageTheme.dark(textTheme: StorageTextTheme.xLargeTextTheme),
      );
    });

    testWidgets('renders LoadingPage', (tester) async {
      await tester.pumpWidget(const App());

      expect(find.byType(ResponsiveLayoutBuilder), findsOneWidget);
      expect(find.byType(LandingPage), findsOneWidget);
    });
  });
}
