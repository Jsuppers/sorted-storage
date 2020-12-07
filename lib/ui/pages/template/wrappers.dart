import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/cookie_service.dart';
import 'package:web/ui/footer/footer.dart';
import 'package:web/ui/navigation/drawer/drawer.dart';
import 'package:web/ui/navigation/navigation_bar/navigation.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/theme/theme.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget widget;
  final bool requiresAuthentication;
  final bool isViewMode;
  final String targetRoute;
  final bool includeNavigation;

  const LayoutWrapper(
      {Key key,
      this.widget,
      this.requiresAuthentication = false,
      this.targetRoute,
      this.includeNavigation = true,
      this.isViewMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.requiresAuthentication || this.isViewMode) {
      return BlocBuilder<AuthenticationBloc, usr.User>(
          builder: (context, user) {
        if (user == null && !this.isViewMode) {
          return Content(
              widget: LoginPage(targetRoute: targetRoute),
              user: user,
              includeNavigation: includeNavigation,
              requiresAuthentication: requiresAuthentication);
        }
        if (!this.isViewMode) {
          BlocProvider.of<TimelineBloc>(context)
              .add(TimelineEvent(TimelineMessageType.retrieve_stories));
        }
        return Content(
            widget: widget,
            user: user,
            includeNavigation: includeNavigation,
            requiresAuthentication: requiresAuthentication);
      });
    } else {
      return Content(
        widget: widget,
        user: null,
        includeNavigation: includeNavigation,
        requiresAuthentication: requiresAuthentication,
      );
    }
  }
}

class Content extends StatefulWidget {
  const Content({
    Key key,
    @required this.widget,
    this.user,
    this.includeNavigation = true,
    this.requiresAuthentication,
  }) : super(key: key);

  final Widget widget;
  final usr.User user;
  final bool includeNavigation;
  final bool requiresAuthentication;

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => CookieService.showCookie(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(user: widget.user),
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) => Container(
          width: sizingInformation.screenSize.width,
          height: sizingInformation.screenSize.height,
          decoration: myBackgroundDecoration,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                widget.includeNavigation
                    ? NavigationBar(user: widget.user)
                    : Container(),
                widget.widget,
                Footer(width: sizingInformation.screenSize.width)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
