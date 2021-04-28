import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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

/// route enums
enum route {
  documents,
  media,
  view,
  login,
  policy,
  terms,
  error,
  home,
  profile,
  folders
}

/// map of route paths
const Map<route, String> routePaths = <route, String>{
  route.documents: '/documents',
  route.media: '/media',
  route.view: '/view',
  route.login: '/login',
  route.policy: '/policy',
  route.terms: '/terms',
  route.error: '/error',
  route.home: '/home',
  route.folders: '/folders',
  route.profile: '/profile'
};

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
          isViewMode: baseRoute == routePaths[route.view],
          requiresAuthentication: _pageRequiresAuthentication(baseRoute),
          showAddButton: _showAddButton(baseRoute),
          routingData: routingData),
    );
  }

  static bool _pageRequiresAuthentication(String baseRoute) {
    return baseRoute == routePaths[route.media] ||
        baseRoute == routePaths[route.documents] ||
        baseRoute == routePaths[route.profile] ||
        baseRoute == routePaths[route.folders];
  }

  static bool _showAddButton(String baseRoute) {
    return baseRoute == routePaths[route.media];
  }

  static Widget _getPageContent(String baseRoute, String destination) {
    if (baseRoute == routePaths[route.view]) {
      return ViewPage(destination);
    }
    if (baseRoute == routePaths[route.login]) {
      return LoginPage();
    }
    if (baseRoute == routePaths[route.media]) {
      return MediaPage(destination);
    }
    if (baseRoute == routePaths[route.profile]) {
      return ProfilePage();
    }
    if (baseRoute == routePaths[route.documents]) {
      return DocumentsPage();
    }
    if (baseRoute == routePaths[route.policy]) {
      return PolicyPage();
    }
    if (baseRoute == routePaths[route.terms]) {
      return TermsPage();
    }
    if (baseRoute == routePaths[route.error]) {
      return ErrorPage();
    }
    if (baseRoute == routePaths[route.folders]) {
      return FolderPage(destination);
    }
    if (baseRoute == routePaths[route.home]) {
      return HomePage();
    }
    return HomePage();
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
