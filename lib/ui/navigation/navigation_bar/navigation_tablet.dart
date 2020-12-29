import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/drawer/drawer_icon.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_content.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_desktop.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';

/// Tablet navigation bar
class NavigationBarTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[];
    final User user = BlocProvider.of<AuthenticationBloc>(context).state;
    if (user != null) {
      return NavigationBarDesktop();
    } else {
      content.addAll(<Widget>[
        Row(
          children: <Widget>[
            DrawerIcon(),
            const NavBarLogo(showText: true),
          ],
        ),
        NavigationLogin()
      ]);
    }

    return NavigationContent(content);
  }
}
