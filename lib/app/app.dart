// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/counter/counter.dart';
import 'package:sorted_storage/widgets/helpers/helpers.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorted Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      builder: (_, child) {
        return ScrollConfiguration(
          behavior: const RemoveScrollGlow(),
          child: child!,
        );
      },
      home: const CounterPage(),
    );
  }
}
