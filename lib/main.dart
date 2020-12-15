import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/drive/drive_event.dart';
import 'package:web/app/blocs/local_stories/local_stories_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/google_drive.dart';
import 'package:web/route.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

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
  GoogleDrive _googleDrive;
  DriveBloc _driveBloc;
  LocalStoriesBloc _localStoriesBloc;
  CloudStoriesBloc _cloudStoriesBloc;
  CommentHandlerBloc _commentHandler;
  Map<String, TimelineData> _localStories = Map();

  @override
  void initState() {
    super.initState();
    _googleDrive = GoogleDrive();
    _driveBloc = DriveBloc();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _authenticationBloc = AuthenticationBloc();
    _authenticationBloc.add(AuthenticationSilentSignInEvent());
    _localStoriesBloc = LocalStoriesBloc(localStories: _localStories);
    _cloudStoriesBloc =
        CloudStoriesBloc(localStories: _localStories, storage: _googleDrive);
    _commentHandler =
        CommentHandlerBloc(localStories: _localStories, storage: _googleDrive);
  }

  @override
  void dispose() {
    super.dispose();
    _navigationBloc.close();
    _authenticationBloc.close();
    _driveBloc.close();
    _localStoriesBloc.close();
    _cloudStoriesBloc.close();
    _commentHandler.close();
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
        BlocProvider<CloudStoriesBloc>(
          create: (BuildContext context) => _cloudStoriesBloc,
        ),
        BlocProvider<LocalStoriesBloc>(
          create: (BuildContext context) => _localStoriesBloc,
        ),
        BlocProvider<CommentHandlerBloc>(
          create: (BuildContext context) => _commentHandler,
        ),
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
              _googleDrive.setDrive(driveApi);
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
