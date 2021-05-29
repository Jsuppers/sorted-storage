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
import 'package:web/app/models/storage_information.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/cloud_provider/google/google_drive.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/avatar.dart';
import 'package:web/ui/widgets/usage_indicator.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final User? user = BlocProvider.of<AuthenticationBloc>(context).state;
    final GoogleDrive storage = BlocProvider.of<FolderStorageBloc>(context).storage;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Column(
                  children: <Widget>[
                    FutureBuilder<StorageInformation?>(
                      future: storage.getStorageInformation(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Icon(Icons.error));
                        }
                        // Once complete, show your application
                        if (snapshot.connectionState == ConnectionState.done) {
                          final StorageInformation information =
                              snapshot.data as StorageInformation;
                          return MaterialButton(
                            onPressed: () =>
                                URLService.openURL(Constants.upgradeURL),
                            child: UsageIndicator(
                              usage: information.usage,
                              limit: information.limit,
                              percent: information.percent,
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: MaterialButton(
                        hoverElevation: 1.0,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        onPressed: () =>
                            URLService.openURL(Constants.profileURL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Avatar(url: user?.photoUrl ?? '', size: 30.0),
                            const SizedBox(height: 10),
                            Text(
                                user?.email == null
                                    ? ''
                                    : user!.email.toLowerCase().substring(
                                        0,
                                        user.email.length > 30
                                            ? 30
                                            : user.email.length),
                                style: myThemeData.textTheme.caption),
                            const SizedBox(height: 10),
                            Text(user?.displayName ?? '',
                                style: myThemeData.textTheme.bodyText1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Center(
                  child: MaterialButton(
                    minWidth: 190,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                      BlocProvider.of<FolderStorageBloc>(context).add(
                          const FolderStorageEvent(FolderStorageType.newUser));
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationSignOutEvent());
                    },
                    child: const Text('Logout'),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
