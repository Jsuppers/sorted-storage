import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
    String baseRoute = routingData.baseRoute;

    return PageTransition(
      type: PageTransitionType.fade,
      settings: settings,
      child: LayoutWrapper(
          widget: getPageContent(baseRoute, routingData.destination),
          includeNavigation: pageHasNavigationBar(baseRoute),
          requiresAuthentication: pageRequiresAuthentication(baseRoute),
          targetRoute: routingData.route),
    );
  }

  static bool pageHasNavigationBar(String baseRoute) {
    return baseRoute != ViewPage.route;
  }

  static bool pageRequiresAuthentication(String baseRoute) {
    return baseRoute == MediaPage.route || baseRoute == DocumentsPage.route;
  }

  static Widget getPageContent(String baseRoute, String destination) {
    switch (baseRoute) {
      case ViewPage.route:
        return ViewPage(destination: destination);
      case LoginPage.route:
        return LoginPage();
      case MediaPage.route:
        return MediaPage();
      case DocumentsPage.route:
        return DocumentsPage();
      case PolicyPage.route:
        return PolicyPage();
      case TermsPage.route:
        return TermsPage();
      case ErrorPage.route:
        return ErrorPage();
      default:
        return HomePage();
    }
  }
}
