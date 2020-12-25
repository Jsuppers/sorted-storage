import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

class NavigationLogin extends StatelessWidget {
  final bool loggedIn;

  const NavigationLogin({Key key, @required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (loggedIn) {
          BlocProvider.of<CloudStoriesBloc>(context)
              .add(CloudStoriesEvent(CloudStoriesType.newUser));
          BlocProvider.of<AuthenticationBloc>(context)
              .add(AuthenticationSignOutEvent());
        } else {
          BlocProvider.of<NavigationBloc>(context).add(NavigateToLoginEvent());
        }
      },
      child: Text(
        loggedIn ? 'Logout' : 'Login',
        style: Theme.of(context).textTheme.button,
      ),
      color: Theme.of(context).primaryColorDark,
    );
  }
}
