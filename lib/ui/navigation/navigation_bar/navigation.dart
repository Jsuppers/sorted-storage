import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_desktop.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_mobile.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_tablet.dart';

/// Adjusts the navigation bar depending on the screen resolution
class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        child: ScreenTypeLayout(
          mobile: NavigationBarMobile(),
          tablet: NavigationBarTablet(),
          desktop: NavigationBarDesktop(),
        ),
      ),
    );
  }
}
