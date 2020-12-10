import 'package:flutter/material.dart';
import 'package:web/app/extensions/string_extensions.dart';
import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/dynamic/view.dart';
import 'package:web/ui/pages/static/error.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';
import 'package:web/ui/pages/template/wrappers.dart';

class RouteConfiguration {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    var routingData = settings.name.getRoutingData;

    bool requiresAuthentication = false;
    if (routingData.route.startsWith(ViewPage.route)) {
      return _getPageRoute(
          LayoutWrapper(
              isViewMode: true,
              widget: ViewPage(path: routingData.route),
              includeNavigation: false,
              requiresAuthentication: requiresAuthentication),
          settings.name);
    }

    Widget widget;
    String targetRoute = routingData.route;
    switch (routingData.route) {
      case LoginPage.route:
        targetRoute = LoginPage.route;
        widget = LoginPage();
        break;
      case MediaPage.route:
        requiresAuthentication = true;
        widget = MediaPage();
        break;
      case DocumentsPage.route:
        requiresAuthentication = true;
        widget = DocumentsPage();
        break;
      case PolicyPage.route:
        widget = PolicyPage();
        break;
      case TermsPage.route:
        widget = TermsPage();
        break;
      case ErrorPage.route:
        widget = ErrorPage();
        break;
      default:
        widget = HomePage();
        break;
    }

    return _getPageRoute(
        LayoutWrapper(
            widget: widget,
            requiresAuthentication: requiresAuthentication,
            targetRoute: targetRoute),
        settings.name);
  }
}

PageRoute _getPageRoute(Widget child, String routeName) {
  return _FadeRoute(child: child, routeName: routeName);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;

  _FadeRoute({this.child, this.routeName})
      : super(
            settings: RouteSettings(name: routeName),
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                child,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}
