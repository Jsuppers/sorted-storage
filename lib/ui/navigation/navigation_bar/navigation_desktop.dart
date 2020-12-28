import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/ui/navigation/drawer/drawer_icon.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_content.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_menu.dart';
import 'package:web/ui/widgets/side_menu.dart';

/// Desktop navigation bar
class NavigationBarDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[];

    // User is logged in
    if (BlocProvider.of<AuthenticationBloc>(context).state != null) {
      content.addAll(<Widget>[
        Row(
          children: <Widget>[
            DrawerIcon(),
            const NavBarLogo(showText: false),
          ],
        ),
        Container(),
        const NavigationMenu(loggedIn: true),
        const SizedBox(width: 10),
        AvatarWithMenu()
      ]);
    }
    // User is not logged in
    else {
      content.addAll(<Widget>[
        const NavBarLogo(showText: true),
        const NavigationMenu(loggedIn: false),
      ]);
    }

    return NavigationContent(content);
  }
}
