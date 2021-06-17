// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/counter/counter.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        accentColor: const Color(0xFF13B9FF),
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
      ),
      home: const CounterPage(),
    );
  }
}
