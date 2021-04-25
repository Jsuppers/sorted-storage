import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/user.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/route.dart';

/// Login page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, String>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    String? redirectRoute = arguments?[Constants.originalValueKey];
    if (redirectRoute == null ||
        redirectRoute == routePaths[route.login] ||
        redirectRoute == routePaths[route.home] ||
        redirectRoute == routePaths[route.profile] ||
        redirectRoute == '/') {
      redirectRoute = routePaths[route.folders]!;
    }

    return BlocBuilder<AuthenticationBloc, User?>(
      builder: (BuildContext context, User? user) {
        if (user != null) {
          BlocProvider.of<NavigationBloc>(context)
              .add(NavigateToRoute(redirectRoute!));
        }
        return ResponsiveBuilder(
            builder: (BuildContext context, SizingInformation constraints) {
          return SizedBox(
            height: constraints.screenSize.height / 2,
            child: Center(
              child: SizedBox(
                height: 150,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Text('Please sign in',
                            style: myThemeData.textTheme.headline3),
                        const SizedBox(height: 7.0),
                        const SizedBox(width: 100, child: Divider(thickness: 1)),
                        const SizedBox(height: 7.0),
                        GoogleAuthButton(
                          onPressed: () =>
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(AuthenticationSignInEvent())
                          ,
                          darkMode: true,
                        ),
                      ],
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
}
