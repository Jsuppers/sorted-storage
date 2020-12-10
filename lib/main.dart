import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/drive/drive_event.dart';
import 'package:web/app/blocs/media_cache/media_cache_bloc.dart';
import 'package:web/app/blocs/media_cache/media_cache_event.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/route.dart';
import 'package:web/ui/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  AuthenticationBloc _authenticationBloc;
  NavigationBloc _navigationBloc;
  DriveBloc _driveBloc;
  TimelineBloc _timelineBloc;
  MediaCacheBloc _imagesBloc;

  @override
  void initState() {
    super.initState();
    _driveBloc = DriveBloc();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _authenticationBloc = AuthenticationBloc();
    _authenticationBloc.add(AuthenticationSilentSignInEvent());
    _timelineBloc = TimelineBloc();
    _imagesBloc = MediaCacheBloc();
  }

  @override
  void dispose() {
    super.dispose();
    _navigationBloc.close();
    _authenticationBloc.close();
    _driveBloc.close();
    _timelineBloc.close();
    _imagesBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DriveBloc>(
          create: (BuildContext context) => _driveBloc,
        ),
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => _navigationBloc,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => _authenticationBloc,
        ),
        BlocProvider<TimelineBloc>(
          create: (BuildContext context) => _timelineBloc,
        ),
        BlocProvider<MediaCacheBloc>(
          create: (BuildContext context) => _imagesBloc,
        )
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationBloc, usr.User>(
            listener: (context, user) {
              _driveBloc.add(InitialDriveEvent(user: user));
            },
          ),
          BlocListener<DriveBloc, DriveApi>(
            listener: (context, driveApi) {
              _timelineBloc.add(TimelineEvent(TimelineMessageType.update_drive, driveApi: driveApi));
              _imagesBloc.add(MediaCacheUpdateDriveAPIEvent(driveApi));
            },
          ),
        ],
        child: MaterialApp(
          title: 'Sorted Storage',
          theme: myThemeData,
          navigatorKey: _navigatorKey,
          onGenerateRoute: RouteConfiguration.onGenerateRoute,
        ),
      ),
    );
  }
}
