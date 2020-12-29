import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/ui/navigation/drawer/drawer_icon.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_content.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_menu.dart';

/// Mobile navigation bar
class NavigationBarMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[];
    if (BlocProvider.of<AuthenticationBloc>(context).state != null) {
      content.addAll(<Widget>[
        DrawerIcon(),
        Container(),
        const NavigationMenu(loggedIn: true),
        Container()
      ]);
    } else {
      content.addAll(<Widget>[
        Row(
          children: <Widget>[DrawerIcon(), const NavBarLogo(showText: false)],
        ),
        NavigationLogin()
      ]);
    }

    return NavigationContent(content);
  }
}
