part of 'landing_navigation_bloc.dart';

abstract class LandingNavigationEvent {
  const LandingNavigationEvent();
}

class LandingNavigationFloatingActionButtonPressed
    extends LandingNavigationEvent {
  const LandingNavigationFloatingActionButtonPressed(this.context);
  final BuildContext context;
}

class LandingNavigationHomeButtonPressed extends LandingNavigationEvent {
  const LandingNavigationHomeButtonPressed();
}

class LandingNavigationProfileButtonPressed extends LandingNavigationEvent {
  const LandingNavigationProfileButtonPressed();
}

class LandingNavigationDonateButtonPressed extends LandingNavigationEvent {
  const LandingNavigationDonateButtonPressed();
}

class LandingNavigationAboutButtonPressed extends LandingNavigationEvent {
  const LandingNavigationAboutButtonPressed();
}
