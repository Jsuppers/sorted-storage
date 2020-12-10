import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/ui/theme/theme.dart';

class MenuItem {
  String name;
  IconData icon;
  NavigationEvent event;

  MenuItem({this.name, this.icon, this.event});
}

class Menu {
  static List<MenuItem> commonItems() => [
        MenuItem(name: "Home", icon: Icons.home, event: NavigateToHomeEvent()),
      ];

  static List<MenuItem> dashboardItems() => [
        MenuItem(
            name: "Media", icon: Icons.image, event: NavigateToMediaEvent()),
        MenuItem(
            name: "Documents",
            icon: Icons.folder,
            event: NavigateToDocumentsEvent()),
      ];
}

List<Widget> createMenu(BuildContext context, bool loggedIn, bool text) {
  List<Widget> widgets = [];

  if (loggedIn) {
    for (MenuItem menuItem in Menu.dashboardItems()) {
      widgets.add(MaterialButton(
        child: text
            ? Row(
                children: [
                  Icon(menuItem.icon),
                  SizedBox(width: 10),
                  Text(
                    menuItem.name,
                    style: myThemeData.textTheme.headline6,
                  ),
                ],
              )
            : Icon(menuItem.icon),
        onPressed: () =>
            BlocProvider.of<NavigationBloc>(context).add(menuItem.event),
      ));
    }
  } else {
    for (MenuItem menuItem in Menu.commonItems()) {
      widgets.add(MaterialButton(
        onPressed: () =>
            BlocProvider.of<NavigationBloc>(context).add(menuItem.event),
        child: Text(
          menuItem.name,
          style: myThemeData.textTheme.headline6,
        ),
      ));
    }
  }

  return widgets;
}
