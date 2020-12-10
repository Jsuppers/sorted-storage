import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_desktop.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_mobile.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_tablet.dart';

class NavigationBar extends StatelessWidget {
  final User user;

  const NavigationBar({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        child: ScreenTypeLayout(
          mobile: NavigationBarMobile(user: user),
          tablet: NavigationBarTablet(user: user),
          desktop: NavigationBarDesktop(user: user),
        ),
      ),
    );
  }
}
