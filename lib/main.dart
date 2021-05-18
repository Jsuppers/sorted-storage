// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:url_strategy/url_strategy.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/drive/drive_event.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/google_drive.dart';
import 'package:web/route.dart';
import 'package:web/ui/theme/theme.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// Main Parent Widget
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late GoogleDrive _googleDrive;
  late DriveBloc _driveBloc;
  late NavigationBloc _navigationBloc;
  late CloudStoriesBloc _cloudStoriesBloc;

  @override
  void initState() {
    super.initState();
    _googleDrive = GoogleDrive();
    _driveBloc = DriveBloc();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _cloudStoriesBloc = CloudStoriesBloc(
        storage: _googleDrive, navigationBloc: _navigationBloc);
  }

  @override
  void dispose() {
    super.dispose();
    _driveBloc.close();
    _navigationBloc.close();
    _cloudStoriesBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<DriveBloc>(
          create: (BuildContext context) => _driveBloc,
        ),
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => _navigationBloc,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(),
        ),
        BlocProvider<CloudStoriesBloc>(
          create: (BuildContext context) => _cloudStoriesBloc,
        ),
        BlocProvider<EditorBloc>(
            create: (BuildContext context) => EditorBloc(
                storage: _googleDrive,
                navigationBloc: _navigationBloc,
                cloudStoriesBloc: _cloudStoriesBloc)),
        BlocProvider<CookieNoticeBloc>(
          create: (BuildContext context) => CookieNoticeBloc(),
        ),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<AuthenticationBloc, usr.User?>(
            listener: (BuildContext context, usr.User? user) {
              _cloudStoriesBloc
                  .add(const CloudStoriesEvent(CloudStoriesType.newUser));
              _driveBloc.add(InitialDriveEvent(user: user));
            },
          ),
          BlocListener<DriveBloc, DriveApi?>(
            listener: (BuildContext context, DriveApi? driveApi) {
              _googleDrive.driveApi = driveApi;
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
