// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:web/app/models/base_route.dart';
import 'package:web/app/models/routing_data.dart';
import 'package:web/ui/pages/dynamic/folder.dart';
import 'package:web/ui/pages/dynamic/folders.dart';
import 'package:web/ui/pages/dynamic/profile.dart';
import 'package:web/ui/pages/static/error.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';
import 'package:web/ui/pages/template/wrappers.dart';

class PageContent {
  PageContent({required this.page, this.requiresAuthentication = false});

  Widget page;
  bool requiresAuthentication;
}

/// class for various routing methods
class RouteConfiguration {
  /// create a page depending on route
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final RoutingData routingData =
        RouteConfiguration.getRoutingData(settings.name);
    final String baseRoute = routingData.baseRoute;
    final PageContent pageContent =
        _getPageContent(baseRoute, routingData.destination);

    return PageTransition<dynamic>(
      type: PageTransitionType.fade,
      settings: settings,
      child: LayoutWrapper(
          widget: pageContent.page,
          requiresAuthentication: pageContent.requiresAuthentication,
          routingData: routingData),
    );
  }

  static PageContent _getPageContent(String baseRoute, String destination) {
    final BaseRoute currentRoute = BaseRoute.values.firstWhere(
        (BaseRoute br) => br.toRouteString() == baseRoute, orElse: () {
      if (baseRoute.isEmpty || baseRoute.length == 1) {
        return BaseRoute.home;
      }
      return BaseRoute.show;
    });

    switch (currentRoute) {
      case BaseRoute.login:
        return PageContent(page: LoginPage());
      case BaseRoute.policy:
        return PageContent(page: PolicyPage());
      case BaseRoute.terms:
        return PageContent(page: TermsPage());
      case BaseRoute.error:
        return PageContent(page: ErrorPage());
      case BaseRoute.home:
        return PageContent(page: HomePage());
      case BaseRoute.profile:
        return PageContent(page: ProfilePage(), requiresAuthentication: true);
      case BaseRoute.folders:
        return PageContent(
            page: FoldersPage(), requiresAuthentication: true);
      case BaseRoute.folder:
        return PageContent(
            page: FolderPage(destination), requiresAuthentication: true);
      case BaseRoute.show:
        return PageContent(page: FolderPage(baseRoute.replaceFirst('/', '')));
    }
  }

  static RoutingData getRoutingData(String? path) {
    final Uri uriData = Uri.parse(path ?? '');
    final RegExp regExp = RegExp('(/.*?)(/.*)');
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
