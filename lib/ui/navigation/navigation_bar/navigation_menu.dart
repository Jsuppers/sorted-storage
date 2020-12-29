import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/menu_item.dart';
import 'package:web/app/services/menu_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/theme/theme.dart';

/// navigation menu
class NavigationMenu extends StatelessWidget {
  // ignore: public_member_api_docs
  const NavigationMenu({Key key, this.loggedIn}) : super(key: key);

  /// whether there is an active user
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = <Widget>[];

    if (loggedIn) {
      for (final MenuItem menuItem in MenuService.dashboardItems()) {
        widgets.add(
          MaterialButton(
            onPressed: () =>
                BlocProvider.of<NavigationBloc>(context).add(menuItem.event),
            child: Row(
              children: <Widget>[
                Icon(menuItem.icon),
                const SizedBox(width: 10),
                Text(
                  menuItem.text,
                  style: myThemeData.textTheme.headline6,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      for (final MenuItem menuItem in MenuService.commonItems()) {
        widgets.add(
          MaterialButton(
            onPressed: () =>
                BlocProvider.of<NavigationBloc>(context).add(menuItem.event),
            child: Text(
              menuItem.text,
              style: myThemeData.textTheme.headline6,
            ),
          ),
        );
      }
      widgets.addAll(<Widget>[const SizedBox(width: 10), NavigationLogin()]);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }
}
