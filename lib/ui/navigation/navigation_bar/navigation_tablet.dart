import 'package:flutter/material.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_desktop.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';

class NavigationBarTablet extends StatelessWidget {
  final User user;

  const NavigationBarTablet({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> content;
    if (user != null) {
      return NavigationBarDesktop(user: user);
    } else {
      content = [
        Row(
          children: [
            NavigationMenu(),
            NavBarLogo(showText: true),
          ],
        ),
        NavigationLogin(loggedIn: false)
      ];
    }

    return NavigationContent(children: content);
  }
}

class NavigationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 25,
      icon: Icon(Icons.menu, size: 24),
      color: Color(0xFF293040),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

class NavigationContent extends StatelessWidget {
  final List<Widget> children;

  const NavigationContent({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children),
    );
  }
}
