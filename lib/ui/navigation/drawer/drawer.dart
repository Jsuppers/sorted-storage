import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/drawer/drawer_item.dart';
import 'package:web/ui/navigation/menu.dart';
import 'package:web/ui/widgets/avatar.dart';

class NavigationDrawer extends StatelessWidget {
  final User user;

  const NavigationDrawer({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) => Container(
        height: sizingInformation.screenSize.height,
        width: 300,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: createMenu(context, user),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: MaterialButton(
                color: Color(0xFFFF813F),
                minWidth: 150,
                onPressed: () {
                  BlocProvider.of<NavigationBloc>(context).add(NavigateToDonate());
                },
                child: Container(
                    width: 150,
                    child: Image.asset("assets/images/bmc.png")),
              ),
            )
          ],
        ),
      ),
    );
  }
}

List<Widget> createMenu(BuildContext context, User user) {
  List<Widget> widgets = [];


  if (user != null) {
    widgets.add(SizedBox(height: 20));
    widgets.add(GestureDetector(
        onTap: () =>
          BlocProvider.of<NavigationBloc>(context).add(NavigateToChangeProfileEvent()),
        child: Avatar(url: user.photoUrl, size: 100.0)));
    widgets.add(SizedBox(height: 20));
    for (MenuItem menuItem in Menu.loggedInItems()) {
      widgets.add(DrawerItem(
          title: menuItem.name, icon: menuItem.icon, event: menuItem.event));
    }
    widgets.add(Divider(height: 20, thickness: 0.5, indent: 20, endIndent: 20));
  }
  for (MenuItem menuItem in Menu.commonItems()) {
    widgets.add(DrawerItem(
        title: menuItem.name, icon: menuItem.icon, event: menuItem.event));
  }

  return widgets;
}
