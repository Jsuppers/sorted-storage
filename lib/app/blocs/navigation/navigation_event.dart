import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';

abstract class NavigationEvent {
  final String route;
  final bool requiresAuthentication;
  const NavigationEvent({this.route = "", this.requiresAuthentication = false});
}

class NavigatorPopEvent extends NavigationEvent{}

class NavigateToHomeEvent extends NavigationEvent{
  NavigateToHomeEvent() : super(route: HomePage.route);
}

class NavigateToLoginEvent extends NavigationEvent{
  NavigateToLoginEvent() : super(route: LoginPage.route);
}

class NavigateToMediaEvent extends NavigationEvent{
  NavigateToMediaEvent() : super(route: MediaPage.route, requiresAuthentication: true);
}

class NavigateToDocumentsEvent extends NavigationEvent{
  NavigateToDocumentsEvent() : super(route: DocumentsPage.route, requiresAuthentication: true);
}

class NavigateToTermsEvent extends NavigationEvent{
  NavigateToTermsEvent() : super(route: TermsPage.route);
}

class NavigateToPrivacyEvent extends NavigationEvent{
  NavigateToPrivacyEvent() : super(route: PolicyPage.route);
}
