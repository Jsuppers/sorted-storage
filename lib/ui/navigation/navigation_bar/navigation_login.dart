import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// Login button
class NavigationLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool loggedIn =
        BlocProvider.of<AuthenticationBloc>(context).state != null;
    return MaterialButton(
      onPressed: () {
        if (loggedIn) {
          BlocProvider.of<CloudStoriesBloc>(context)
              .add(const CloudStoriesEvent(CloudStoriesType.newUser));
          BlocProvider.of<AuthenticationBloc>(context)
              .add(AuthenticationSignOutEvent());
        } else {
          BlocProvider.of<NavigationBloc>(context).add(NavigateToLoginEvent());
        }
      },
      color: Theme.of(context).primaryColorDark,
      child: Text(
        loggedIn ? 'Logout' : 'Login',
        style: Theme.of(context).textTheme.button,
      ),
    );
  }
}
