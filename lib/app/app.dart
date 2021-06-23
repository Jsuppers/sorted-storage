// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/view/lading_page.dart';
import 'package:sorted_storage/themes/themes.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
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
      home: const LandingPage(),
    );
  }
}
