import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/drawer/drawer_item.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';

/// the drawer which changes depending on if the user is signed in or not
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = BlocProvider.of<AuthenticationBloc>(context).state;

    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation info) => Container(
        height: info.screenSize.height,
        width: 300,
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16),
        ]),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                  splashRadius: 25,
                  icon: const Icon(Icons.arrow_back_ios, size: 24),
                  color: myThemeData.primaryColorDark,
                  onPressed: () => BlocProvider.of<NavigationBloc>(context)
                      .add(NavigatorPopEvent()),
                )
              ],
              title: NavBarLogo(),
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: _createDrawerMenu(user),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              // fillOverscroll: true, // Set true to change overscroll behavior. Purely preference.
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: MaterialButton(
                    color: const Color(0xFFFF813F),
                    minWidth: 150,
                    onPressed: () => URLService.openURL(Constants.donateURL),
                    child: SizedBox(
                        width: 150,
                        child: Image.asset('assets/images/bmc.png')),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _createDrawerMenu(User user) {
    if (user == null) {
      return <Widget>[DrawerItem('Login', Icons.login, NavigateToLoginEvent())];
    }
    final List<Widget> widgets = <Widget>[];
    widgets.add(DrawerItem('Home', Icons.home, NavigateToHomeEvent()));
    widgets.add(DrawerItem('Add', Icons.add, null));

    return widgets;
  }
}
