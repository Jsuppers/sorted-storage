import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// DrawerItem is a formatted item for the drawer
class DrawerItem extends StatelessWidget {
  /// A drawer item contains a title, icon and an event which is sent when
  /// clicked
  const DrawerItem(this._title, this._icon, this._event);

  final String _title;
  final IconData _icon;
  final NavigationEvent _event;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if (_event is NavigateToLoginEvent) {
          BlocProvider.of<CloudStoriesBloc>(context)
              .add(const CloudStoriesEvent(CloudStoriesType.newUser));
          BlocProvider.of<AuthenticationBloc>(context)
              .add(AuthenticationSignOutEvent());
        } else {
          BlocProvider.of<NavigationBloc>(context).add(_event);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
        child: Row(
          children: <Widget>[
            Icon(_icon),
            const SizedBox(width: 30),
            Text(
              _title,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }
}
