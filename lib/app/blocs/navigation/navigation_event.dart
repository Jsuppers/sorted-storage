// Project imports:
import 'package:web/app/models/base_route.dart';

/// abstract class for navigation events
abstract class NavigationEvent {
  /// constructor
  const NavigationEvent(
      {this.route = '', this.requiresAuthentication = false, this.arguments});

  /// route where to navigate to
  final String route;

  final Object? arguments;

  /// if this pages requires a signed in user
  final bool requiresAuthentication;
}

class NavigateToRoute extends NavigationEvent {
  /// constructor which sets route to the home page
  NavigateToRoute(String route) : super(route: route);
}

/// pop dialog
class NavigatorPopDialogEvent extends NavigationEvent {}

/// pops the current route
class NavigatorPopEvent extends NavigationEvent {}

/// event to navigate to the home page
class NavigateToHomeEvent extends NavigationEvent {
  /// constructor which sets route to the home page
  NavigateToHomeEvent() : super(route: BaseRoute.about.toRouteString());
}

/// event to navigate to the login page
class NavigateToLoginEvent extends NavigationEvent {
  /// constructor which sets route to the login page
  NavigateToLoginEvent({Object? arguments})
      : super(route: BaseRoute.login.toRouteString(), arguments: arguments);
}

/// event to navigate to the media page
class NavigateToMediaEvent extends NavigationEvent {
  /// constructor which sets route to the media page
  NavigateToMediaEvent({required String folderId})
      : super(
            route: '${BaseRoute.folders.toRouteString()}/$folderId',
            requiresAuthentication: true);
}

/// event to navigate to the media page
class NavigateToFolderEvent extends NavigationEvent {
  /// constructor which sets route to the media page
  NavigateToFolderEvent()
      : super(
            route: BaseRoute.home.toRouteString(),
            requiresAuthentication: true);
}

/// event to navigate to the media page
class NavigateToProfileEvent extends NavigationEvent {
  /// constructor which sets route to the media page
  NavigateToProfileEvent()
      : super(
            route: BaseRoute.profile.toRouteString(),
            requiresAuthentication: true);
}

/// event to navigate to the terms page
class NavigateToTermsEvent extends NavigationEvent {
  /// constructor which sets route to the terms page
  NavigateToTermsEvent() : super(route: BaseRoute.terms.toRouteString());
}

/// event to navigate to the privacy page
class NavigateToPrivacyEvent extends NavigationEvent {
  /// constructor which sets route to the privacy page
  NavigateToPrivacyEvent() : super(route: BaseRoute.policy.toRouteString());
}
