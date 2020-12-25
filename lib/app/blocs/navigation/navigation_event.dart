import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';

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
  NavigateToHomeEvent() : super(route: HomePage.route);
}

/// event to navigate to the login page
class NavigateToLoginEvent extends NavigationEvent {
  /// constructor which sets route to the login page
  NavigateToLoginEvent() : super(route: LoginPage.route);
}

/// event to navigate to the media page
class NavigateToMediaEvent extends NavigationEvent {
  /// constructor which sets route to the media page
  NavigateToMediaEvent()
      : super(route: MediaPage.route, requiresAuthentication: true);
}

/// event to navigate to the documents page
class NavigateToDocumentsEvent extends NavigationEvent {
  /// constructor which sets route to the documents page
  NavigateToDocumentsEvent()
      : super(route: DocumentsPage.route, requiresAuthentication: true);
}

/// event to navigate to the terms page
class NavigateToTermsEvent extends NavigationEvent {
  /// constructor which sets route to the terms page
  NavigateToTermsEvent() : super(route: TermsPage.route);
}

/// event to navigate to the privacy page
class NavigateToPrivacyEvent extends NavigationEvent {
  /// constructor which sets route to the privacy page
  NavigateToPrivacyEvent() : super(route: PolicyPage.route);
}
