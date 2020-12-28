
import 'package:flutter/material.dart';
import 'package:web/ui/theme/theme.dart';

/// icon to open drawer
class DrawerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 25,
      icon: const Icon(Icons.menu, size: 24),
      color: myThemeData.primaryColorDark,
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}
