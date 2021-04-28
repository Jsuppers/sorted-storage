// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/routing_data.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/footer/footer.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

/// layout widget
class LayoutWrapper extends StatelessWidget {
  // ignore: public_member_api_docs
  const LayoutWrapper(
      {Key? key,
      required this.widget,
      this.requiresAuthentication = false,
      this.routingData,
      this.isViewMode = false})
      : super(key: key);

  /// main widget
  final Widget widget;

  /// whether this widget requires a authenticated user
  final bool requiresAuthentication;

  /// whether this widget is on the
  final bool isViewMode;

  /// the targeted route
  final RoutingData? routingData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, usr.User?>(
        builder: (BuildContext context, usr.User? user) {
      if (requiresAuthentication && user == null) {
        final Map<String, String> queryParameters = <String, String>{};
        if (routingData?.queryParameters != null) {
          routingData?.queryParameters.forEach((String key, String value) {
            queryParameters.putIfAbsent(key, () => value);
          });
        }
        queryParameters.putIfAbsent(
            Constants.originalValueKey, () => routingData!.route);
        BlocProvider.of<NavigationBloc>(context)
            .add(NavigateToLoginEvent(arguments: queryParameters));
        return StaticLoadingLogo();
      }
      return Content(
          widget: widget,
          includeNavigation: !isViewMode,
          routingData: routingData);
    });
  }
}

/// content styling
class Content extends StatefulWidget {
  // ignore: public_member_api_docs
  const Content(
      {Key? key,
      required this.widget,
      this.routingData,
      this.includeNavigation = true})
      : super(key: key);

  /// main widget
  final Widget widget;

  /// should include the navigation bar
  final bool includeNavigation;

  /// the targeted route
  final RoutingData? routingData;

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => BlocProvider.of<CookieNoticeBloc>(context).showCookie(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation sizingInformation) =>
            Container(
          width: sizingInformation.screenSize.width,
          height: sizingInformation.screenSize.height,
          decoration: myBackgroundDecoration,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: widget.widget,
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Footer(sizingInformation.screenSize.width)),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: CustomActionButton(),
    );
  }
}

class CustomActionButton extends StatefulWidget {
  @override
  _CustomActionButtonState createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends State<CustomActionButton>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  IconData iconData = FontAwesomeIcons.smile;
  usr.User? user;

  @override
  void initState() {
    user = BlocProvider.of<AuthenticationBloc>(context).state;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final CurvedAnimation curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, usr.User?>(
      listener: (BuildContext context, usr.User? user) {
        setState(() => this.user = user);
      },
      child: Visibility(
        visible: user != null,
        child: FloatingActionBubble(
          // Menu items
          items: <Bubble>[
            // Floating action menu item
            Bubble(
              title: 'Donate',
              iconColor: Colors.pink,
              bubbleColor: Colors.white,
              icon: Icons.favorite,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.pink),
              onPress: () => URLService.openURL(Constants.donateURL),
            ),
            Bubble(
              title: 'Profile',
              iconColor: Colors.green,
              bubbleColor: Colors.white,
              icon: Icons.person,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.green),
              onPress: () => BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToProfileEvent()),
            ),
            //Floating action menu item
            Bubble(
              title: 'Home',
              iconColor: Colors.blue,
              bubbleColor: Colors.white,
              icon: Icons.home,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.blue),
              onPress: () => BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToFolderEvent()),
            ),
          ],

          // animation controller
          animation: _animation,

          // On pressed change animation state
          onPress: () {
            setState(() {
              if (_animationController.isCompleted) {
                iconData = FontAwesomeIcons.smile;
                _animationController.reverse();
              } else {
                iconData = FontAwesomeIcons.grin;
                _animationController.forward();
              }
            });
          },

          backGroundColor: Colors.white,
          iconData: iconData,
          iconColor: myThemeData.primaryColorDark,
        ),
      ),
    );
  }
}

//
//class ActionButton extends StatefulWidget {
//  @override
//  _ActionButtonState createState() => _ActionButtonState();
//}
//
//class _ActionButtonState extends State<ActionButton> {
//  bool saving = false;
//
//  @override
//  Widget build(BuildContext context) {
//    return BlocListener<EditorBloc, EditorState>(
//      listener: (BuildContext context, EditorState state) {
//        if (state.type == EditorType.syncingState) {
//          setState(() {
//            saving = state.data == SavingState.saving;
//          });
//        }
//      },
//      child: FloatingActionButton(
//        onPressed: () {
//          if (saving == true) {
//            return;
//          }
//          setState(() {
//            saving = true;
//          });
//          final String mediaFile =
//              BlocProvider
//                  .of<CloudStoriesBloc>(context)
//                  .currentMediaFileId;
//          BlocProvider.of<EditorBloc>(context).add(EditorEvent(
//              EditorType.createStory,
//              parentID: mediaFile,
//              mainEvent: true));
//        },
//        backgroundColor: myThemeData.primaryColorDark,
//        child: saving
//            ? const IconSpinner(
//          icon: Icons.sync,
//          color: Colors.white,
//          isSpinning: true, // change it to true or false
//        )
//            : const Icon(
//          Icons.add,
//          color: Colors.white,
//        ),
//      ),
//    );
//  }
//}
