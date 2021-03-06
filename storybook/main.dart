import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/services/cloud_provider/google/google_drive.dart';
import 'package:web/app/services/cloud_provider/storage_service.dart';
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/ui/layouts/basic/basic.dart';
import 'package:web/ui/layouts/timeline/timeline.dart';

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
  late StorageService _storage;
  late NavigationBloc _navigationBloc;
  late FolderStorageBloc _folderStorageBloc;

  @override
  void initState() {
    super.initState();
    _storage = GoogleDrive();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _folderStorageBloc =
        FolderStorageBloc(storage: _storage, navigationBloc: _navigationBloc);
  }

  @override
  void dispose() {
    super.dispose();
    _navigationBloc.close();
    _folderStorageBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => _navigationBloc,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(
            storage: _storage,
          ),
        ),
        BlocProvider<FolderStorageBloc>(
          create: (BuildContext context) => _folderStorageBloc,
        ),
        BlocProvider<EditorBloc>(
            create: (BuildContext context) => EditorBloc(
                storage: _storage,
                navigationBloc: _navigationBloc,
                folderStorageBloc: _folderStorageBloc)),
        BlocProvider<CookieNoticeBloc>(
          create: (BuildContext context) => CookieNoticeBloc(),
        ),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<AuthenticationBloc, usr.User?>(
            listener: (BuildContext context, usr.User? user) {
              _folderStorageBloc
                  .add(const FolderStorageEvent(FolderStorageType.newUser));
            },
          ),
        ],
        child: Storybook(
          children: [
            Story(
                name: 'Time line empty',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TimelineLayout(
                          folder: exampleFolderSingle(0, 0),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
            Story(
                name: 'Time line single',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TimelineLayout(
                          folder: exampleFolderSingle(1, 5),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
            Story(
                name: 'Time line ten',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TimelineLayout(
                          folder: exampleFolderSingle(10, 5),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
            Story(
                name: 'Basic empty',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: BasicLayout(
                          folder: exampleFolderSingle(0, 5),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
            Story(
                name: 'Basic one',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: BasicLayout(
                          folder: exampleFolderSingle(1, 5),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
            Story(
                name: 'Basic ten',
                builder: (_, k) => ResponsiveBuilder(builder:
                        (BuildContext context, SizingInformation constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: BasicLayout(
                          folder: exampleFolderSingle(10, 5),
                          width: constraints.localWidgetSize.width,
                          height: constraints.localWidgetSize.height,
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }

  Folder exampleFolderSingle(int children, int files) {
    final List<Folder> subFolders = <Folder>[];
    Map<String, dynamic> metadata = <String, dynamic>{};
    Map<String, FileData> folderFiles = <String, FileData>{};
    for (int i = 0; i < files; i++) {
      folderFiles.putIfAbsent(
          i.toString(),
          () => FileData(
                thumbnailURL: 'https://robohash.org/' + i.toString(),
                id: i.toString(),
                name: 'this is folder ' + i.toString(),
              ));
    }

    metadata.setDescription('A description');
    for (int i = 0; i < children; i++) {
      subFolders.add(Folder(
        title: 'Long text folder example  $i',
        emoji: Emojis.rocket,
        metadata: metadata,
        loaded: true,
      ));
    }
    return Folder(
      title: 'Example Title',
      emoji: Emojis.rocket,
      metadata: metadata,
      files: folderFiles,
      subFolders: subFolders,
      loaded: true,
    );
  }
}
