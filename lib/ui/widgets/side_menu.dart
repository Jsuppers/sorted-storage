import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/storage_information.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/avatar.dart';
import 'package:web/ui/widgets/usage_indicator.dart';

// ignore: public_member_api_docs
class AvatarWithMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = BlocProvider.of<AuthenticationBloc>(context).state;

    // ignore: avoid_void_async
    void _showPopupMenu() async {
      await showMenu(
        useRootNavigator: true,
        elevation: 1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        context: context,
        position: const RelativeRect.fromLTRB(double.maxFinite, 120, 24, 0),
        items: <PopupMenuEntry<dynamic>>[
          PopupMenuItem<dynamic>(
            enabled: false,
            child: Column(
              children: <Widget>[
                FutureBuilder<StorageInformation>(
                  future: GoogleStorageService.getStorageInformation(
                      BlocProvider.of<DriveBloc>(context).state),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    onPressed: () => URLService.openURL(Constants.profileURL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Avatar(url: user.photoUrl, size: 100.0),
                        const SizedBox(height: 10),
                        Text(
                            user.email.toLowerCase().substring(
                                0,
                                user.email.length > 30
                                    ? 30
                                    : user.email.length),
                            style: myThemeData.textTheme.caption),
                        const SizedBox(height: 10),
                        Text(user.displayName,
                            style: myThemeData.textTheme.bodyText1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuItem<dynamic>(
            enabled: false,
            child: Divider(),
          ),
          PopupMenuItem<dynamic>(
            enabled: false,
            child: Center(
              child: MaterialButton(
                minWidth: 190,
                onPressed: () {
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigatorPopEvent());
                  BlocProvider.of<CloudStoriesBloc>(context)
                      .add(const CloudStoriesEvent(CloudStoriesType.newUser));
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(AuthenticationSignOutEvent());
                },
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _showPopupMenu();
        },
        child: Avatar(url: user.photoUrl, size: 45.0),
      ),
    );
  }
}
