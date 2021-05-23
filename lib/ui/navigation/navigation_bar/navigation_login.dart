// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
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
          BlocProvider.of<FolderStorageBloc>(context)
              .add(const FolderStorageEvent(FolderStorageType.newUser));
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
