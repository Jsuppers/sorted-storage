import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/routing_data.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/ui/footer/footer.dart';
import 'package:web/ui/navigation/drawer/drawer.dart';
import 'package:web/ui/navigation/navigation_bar/navigation.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/theme/theme.dart';

/// layout widget
class LayoutWrapper extends StatelessWidget {
  // ignore: public_member_api_docs
  const LayoutWrapper(
      {Key key,
      this.widget,
      this.requiresAuthentication = false,
      this.showAddButton = false,
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
  final RoutingData routingData;

  /// ability to add a story
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, usr.User>(
        builder: (BuildContext context, usr.User user) {
      if (requiresAuthentication && user == null) {
        Widget redirectWidget;
        if (routingData.route == '/') {
          redirectWidget = HomePage();
        } else {
          redirectWidget = LoginPage();
        }
        return Content(
          widget: redirectWidget,
          showAddButton: showAddButton,
        );
      }
      return Content(
          widget: widget,
          includeNavigation: !isViewMode,
          showAddButton: showAddButton,
          routingData: routingData);
    });
  }
}

/// content styling
class Content extends StatefulWidget {
  // ignore: public_member_api_docs
  const Content({
    Key key,
    @required this.widget,
    this.includeNavigation = true,
    this.showAddButton,
    this.routingData
  }) : super(key: key);

  /// main widget
  final Widget widget;

  /// should include the navigation bar
  final bool includeNavigation;

  /// ability to add a story
  final bool showAddButton;


  /// the targeted route
  final RoutingData routingData;

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => BlocProvider.of<CookieNoticeBloc>(context).showCookie(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      body: ResponsiveBuilder(
        builder: (BuildContext context, SizingInformation sizingInformation) =>
            Container(
          width: sizingInformation.screenSize.width,
          height: sizingInformation.screenSize.height,
          decoration: myBackgroundDecoration,
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  if (widget.includeNavigation)
                    NavigationBar()
                  else
                    Container(),
                  widget.widget,
                  Footer(sizingInformation.screenSize.width)
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: widget.showAddButton,
        child: FloatingActionButton(
          onPressed: () {

            // StaticLoadingLogo()

            final String mediaFile =
                BlocProvider.of<CloudStoriesBloc>(context).currentMediaFileId;
            BlocProvider.of<EditorBloc>(context)
                .add(EditorEvent(EditorType.createStory,
                parentID: mediaFile,
            mainEvent: true));
          },
          backgroundColor: myThemeData.primaryColorDark,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
