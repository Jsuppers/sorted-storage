import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/menu_item.dart';
import 'package:web/app/services/menu_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/drawer/drawer_item.dart';
import 'package:web/ui/widgets/avatar.dart';

/// the drawer which changes depending on if the user is signed in or not
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation info) => Container(
        height: info.screenSize.height,
        width: 300,
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: _createDrawerMenu(
                    BlocProvider.of<AuthenticationBloc>(context).state),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: MaterialButton(
                color: const Color(0xFFFF813F),
                minWidth: 150,
                onPressed: () => URLService.openURL(Constants.donateURL),
                child: SizedBox(
                    width: 150, child: Image.asset('assets/images/bmc.png')),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _createDrawerMenu(User user) {
    final List<Widget> widgets = <Widget>[];

    if (user != null) {
      widgets.addAll(<Widget>[
        const SizedBox(height: 20),
        GestureDetector(
            onTap: () => URLService.openURL(Constants.profileURL),
            child: Avatar(url: user.photoUrl, size: 100.0)),
        const SizedBox(height: 20),
        DrawerItem('Logout', Icons.exit_to_app, NavigateToLoginEvent())
      ]);
      widgets.add(
          const Divider(height: 20, thickness: 0.5, indent: 20, endIndent: 20));
    }
    for (final MenuItem menuItem in MenuService.commonItems()) {
      widgets.add(DrawerItem(menuItem.text, menuItem.icon, menuItem.event));
    }

    return widgets;
  }
}


