import 'package:web/route.dart';

/// abstract class for navigation events
abstract class NavigationEvent {
  /// constructor
  const NavigationEvent({this.route = '', this.requiresAuthentication = false});

  /// route where to navigate to
  final String route;

  /// if this pages requires a signed in user
  final bool requiresAuthentication;
}

/// pops the current route
class NavigatorPopEvent extends NavigationEvent {}

/// event to navigate to the home page
class NavigateToHomeEvent extends NavigationEvent {
  /// constructor which sets route to the home page
  NavigateToHomeEvent() : super(route: routePaths[route.home]);
}

/// event to navigate to the login page
class NavigateToLoginEvent extends NavigationEvent {
  /// constructor which sets route to the login page
  NavigateToLoginEvent() : super(route: routePaths[route.login]);
}

/// event to navigate to the media page
class NavigateToMediaEvent extends NavigationEvent {
  /// constructor which sets route to the media page
  NavigateToMediaEvent()
      : super(route: routePaths[route.media], requiresAuthentication: true);
}

/// event to navigate to the documents page
class NavigateToDocumentsEvent extends NavigationEvent {
  /// constructor which sets route to the documents page
  NavigateToDocumentsEvent()
      : super(route: routePaths[route.documents], requiresAuthentication: true);
}

/// event to navigate to the terms page
class NavigateToTermsEvent extends NavigationEvent {
  /// constructor which sets route to the terms page
  NavigateToTermsEvent() : super(route: routePaths[route.terms]);
}

/// event to navigate to the privacy page
class NavigateToPrivacyEvent extends NavigationEvent {
  /// constructor which sets route to the privacy page
  NavigateToPrivacyEvent() : super(route: routePaths[route.policy]);
}
