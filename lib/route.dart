import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:web/app/models/base_route.dart';
import 'package:web/app/models/routing_data.dart';
import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/folders.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/dynamic/profile.dart';
import 'package:web/ui/pages/dynamic/view.dart';
import 'package:web/ui/pages/static/error.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';
import 'package:web/ui/pages/template/wrappers.dart';

/// class for various routing methods
class RouteConfiguration {
  static const String _uriRegex = '(/.*?)(/.*)';

  /// create a page depending on route
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final RoutingData routingData =
        RouteConfiguration.getRoutingData(settings.name);
    final String baseRoute = routingData.baseRoute;

    return PageTransition<dynamic>(
      type: PageTransitionType.fade,
      settings: settings,
      child: LayoutWrapper(
          widget: _getPageContent(baseRoute, routingData.destination),
          isViewMode: baseRoute == BaseRoute.view.toRouteString(),
          requiresAuthentication: _pageRequiresAuthentication(baseRoute),
          routingData: routingData),
    );
  }

  static bool _pageRequiresAuthentication(String baseRoute) {
    return baseRoute == BaseRoute.media.toRouteString() ||
        baseRoute == BaseRoute.documents.toRouteString() ||
        baseRoute == BaseRoute.profile.toRouteString() ||
        baseRoute == BaseRoute.folders.toRouteString();
  }

  static Widget _getPageContent(String baseRoute, String destination) {
    final BaseRoute currentRoute = BaseRoute.values.firstWhere(
        (BaseRoute br) => br.toRouteString() == baseRoute,
        orElse: () => BaseRoute.home);

    switch (currentRoute) {
      case BaseRoute.view:
        return ViewPage(destination);
      case BaseRoute.documents:
        return DocumentsPage();
      case BaseRoute.media:
        return MediaPage(destination);
      case BaseRoute.login:
        return LoginPage();
      case BaseRoute.policy:
        return PolicyPage();
      case BaseRoute.terms:
        return TermsPage();
      case BaseRoute.error:
        return ErrorPage();
      case BaseRoute.home:
        return HomePage();
      case BaseRoute.profile:
        return ProfilePage();
      case BaseRoute.folders:
        return FolderPage(destination);
    }
  }

  static RoutingData getRoutingData(String? path) {
    final Uri uriData = Uri.parse(path ?? '');
    final RegExp regExp = RegExp(_uriRegex);
    final Iterable<RegExpMatch> matches = regExp.allMatches(uriData.path);
    String baseRoute = uriData.path;
    String destination = '';
    if (matches.isNotEmpty) {
      final RegExpMatch match = matches.elementAt(0);
      baseRoute = match.group(1)!;
      destination = match.group(2)!.replaceFirst('/', '');
    }

    return RoutingData(
      queryParameters: uriData.queryParameters,
      route: uriData.path,
      baseRoute: baseRoute,
      destination: destination,
    );
  }
}
