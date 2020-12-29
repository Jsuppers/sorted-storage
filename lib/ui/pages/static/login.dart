import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/user.dart';
import 'package:web/route.dart';
import 'package:web/ui/theme/theme.dart';

/// Login page
class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, User>(
      builder: (BuildContext context, User user) {
        if (user != null) {
          BlocProvider.of<NavigationBloc>(context).add(NavigateToMediaEvent());
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  GoogleSignInButton(
                    onPressed: () async {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationSignInEvent());
                    },
                    darkMode: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
