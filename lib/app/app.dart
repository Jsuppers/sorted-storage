// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/presentation/login/view/login_page.dart';
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/utils/services/authentication/repositories/authentication_repository.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authenticationRepository,
  }) : super(key: key);
  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
      ],
      child: ResponsiveLayoutBuilder(
        small: (context, child) => AppView(
          lightTheme:
              StorageTheme().light(textTheme: StorageTextTheme.smallTextTheme),
          darkTheme:
              StorageTheme().dark(textTheme: StorageTextTheme.smallTextTheme),
        ),
        medium: (context, child) => AppView(
          lightTheme:
              StorageTheme().light(textTheme: StorageTextTheme.mediumTextTheme),
          darkTheme:
              StorageTheme().dark(textTheme: StorageTextTheme.mediumTextTheme),
        ),
        large: (context, child) => AppView(
          lightTheme:
              StorageTheme().light(textTheme: StorageTextTheme.largeTextTheme),
          darkTheme:
              StorageTheme().dark(textTheme: StorageTextTheme.largeTextTheme),
        ),
        xLarge: (context, child) => AppView(
          lightTheme:
              StorageTheme().light(textTheme: StorageTextTheme.xLargeTextTheme),
          darkTheme:
              StorageTheme().dark(textTheme: StorageTextTheme.xLargeTextTheme),
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    required this.lightTheme,
    required this.darkTheme,
  }) : super(key: key);

  final ThemeData lightTheme;
  final ThemeData darkTheme;

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
      home: StreamBuilder<User?>(
        stream: context.read<AuthenticationRepository>().authStateChanges,
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }
}
