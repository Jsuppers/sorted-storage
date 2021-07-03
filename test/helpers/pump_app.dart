// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';

class MockThemeBox extends Mock implements Box {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    AuthenticationRepository? authenticationRepository,
  }) async {
    // Use Roboto font instead of tester's default Ahem font
    final _fontLoader = FontLoader('Regular')
      ..addFont(rootBundle.load('assets/fonts/Roboto/Regular.ttf'));
    await _fontLoader.load();

    return pumpWidget(
      _App(
        widget,
        authenticationRepository: authenticationRepository,
      ),
    );
  }
}

class _App extends StatelessWidget {
  _App(
    this.child, {
    Key? key,
    StorageTheme? storageTheme,
    AuthenticationRepository? authenticationRepository,
  })  : _storageTheme = storageTheme ?? StorageTheme(themeBox: MockThemeBox()),
        _authenticationRepository =
            authenticationRepository ?? AuthenticationRepository(),
        super(key: key);

  final Widget child;
  late final StorageTheme _storageTheme;
  late final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
      ],
      child: ResponsiveLayoutBuilder(
        small: (context, child) => _AppView(
          lightTheme:
              _storageTheme.light(textTheme: StorageTextTheme.smallTextTheme),
          darkTheme:
              _storageTheme.dark(textTheme: StorageTextTheme.smallTextTheme),
          child: child,
        ),
        medium: (context, child) => _AppView(
          lightTheme:
              _storageTheme.light(textTheme: StorageTextTheme.mediumTextTheme),
          darkTheme:
              _storageTheme.dark(textTheme: StorageTextTheme.mediumTextTheme),
          child: child,
        ),
        large: (context, child) => _AppView(
          lightTheme:
              _storageTheme.light(textTheme: StorageTextTheme.largeTextTheme),
          darkTheme:
              _storageTheme.dark(textTheme: StorageTextTheme.largeTextTheme),
          child: child,
        ),
        xLarge: (context, child) => _AppView(
          lightTheme:
              _storageTheme.light(textTheme: StorageTextTheme.xLargeTextTheme),
          darkTheme:
              _storageTheme.dark(textTheme: StorageTextTheme.xLargeTextTheme),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({
    Key? key,
    required this.lightTheme,
    required this.darkTheme,
    required this.child,
  }) : super(key: key);

  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorted Storage',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      builder: (_, child) {
        return ScrollConfiguration(
          behavior: const RemoveScrollGlow(),
          child: child!,
        );
      },
      home: child,
    );
  }
}
