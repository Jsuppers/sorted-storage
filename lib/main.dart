// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/comment_handler/comment_handler_bloc.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/drive/drive_event.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/google_drive.dart';
import 'package:web/route.dart';
import 'package:web/ui/theme/theme.dart';

Future<void> main() async {
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
  late Map<String, StoryTimelineData> _cloudStories;

  @override
  void initState() {
    super.initState();
    _cloudStories = <String, StoryTimelineData>{};
    _googleDrive = GoogleDrive();
    _driveBloc = DriveBloc();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _cloudStoriesBloc = CloudStoriesBloc(
        cloudStories: _cloudStories,
        storage: _googleDrive,
        navigationBloc: _navigationBloc);
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
        BlocProvider<CommentHandlerBloc>(
          create: (BuildContext context) => CommentHandlerBloc(
              cloudStories: _cloudStories, storage: _googleDrive),
        ),
        BlocProvider<EditorBloc>(
            create: (BuildContext context) => EditorBloc(
                cloudStories: _cloudStories,
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
