// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/base_route.dart';
import 'package:web/app/models/user.dart';
import 'package:web/constants.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';

/// Login page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, User?>(
      builder: (BuildContext context, User? user) {
        if (user != null) {
          _redirect(context);
        }
        return ResponsiveBuilder(
            builder: (BuildContext context, SizingInformation constraints) {
          return SingleChildScrollView(
            child: SizedBox(
              height: constraints.screenSize.height / 2,
              child: Center(
                child: SizedBox(
                  height: 225,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          const NavBarLogo(height: 40),
                          const SizedBox(
                            width: 100,
                            height: 20,
                            child: Divider(thickness: 1),
                          ),
                          GoogleAuthButton(
                            onPressed: () {
                              BlocProvider.of<AuthenticationBloc>(context)
                                  .add(AuthenticationSignInEvent());
                            },
                            darkMode: true,
                          ),
                          const SizedBox(
                            width: 100,
                            height: 20,
                            child: Divider(thickness: 1),
                          ),
                          Text('By signing up you agree to our',
                              style: myThemeData.textTheme.caption),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                    onTap: () =>
                                        BlocProvider.of<NavigationBloc>(context)
                                            .add(NavigateToPrivacyEvent()),
                                    child: Text('Privacy Policy',
                                        style: myThemeData.textTheme.caption)),
                                Text(' and ',
                                    style: myThemeData.textTheme.caption),
                                InkWell(
                                    onTap: () =>
                                        BlocProvider.of<NavigationBloc>(context)
                                            .add(NavigateToPrivacyEvent()),
                                    child: Text('Terms of Conditions',
                                        style: myThemeData.textTheme.caption)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _redirect(BuildContext context) {
    final Map<String, String>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    String? redirectRoute = arguments?[Constants.originalValueKey];
    if (redirectRoute == null ||
        redirectRoute == BaseRoute.login.toRouteString() ||
        redirectRoute == BaseRoute.about.toRouteString() ||
        redirectRoute == BaseRoute.profile.toRouteString() ||
        redirectRoute == '/') {
      redirectRoute = BaseRoute.home.toRouteString();
    }
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigateToRoute(redirectRoute));
  }
}
