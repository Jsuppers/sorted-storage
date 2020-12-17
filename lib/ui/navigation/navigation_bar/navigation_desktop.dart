import 'package:flutter/material.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/menu.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/widgets/side_menu.dart';

import 'navigation_tablet.dart';

class NavigationBarDesktop extends StatelessWidget {
  final User user;

  const NavigationBarDesktop({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> content;

    if (user != null) {
      content = [
        Row(
          children: [
            NavigationMenu(),
            NavBarLogo(showText: false),
          ],
        ),
        Container(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: createMenu(context, true, true),
        ),
        SizedBox(width: 10),
        AvatarWithMenu(user: user)
      ];
    } else {
      content = [
        NavBarLogo(showText: true),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...createMenu(context, false, true),
            SizedBox(width: 10),
            NavigationLogin(loggedIn: false)
          ],
        )
      ];
    }

    return NavigationContent(children: content);
  }
}


