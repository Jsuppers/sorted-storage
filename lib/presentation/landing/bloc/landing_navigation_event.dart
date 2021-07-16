part of 'landing_navigation_bloc.dart';

abstract class LandingNavigationEvent {
  const LandingNavigationEvent();
}

class LandingNavigationFloatingActionButtonPressed
    extends LandingNavigationEvent {
  const LandingNavigationFloatingActionButtonPressed();
}

class LandingNavigationHomeButtonPressed extends LandingNavigationEvent {
  const LandingNavigationHomeButtonPressed();
}

class LandingNavigationProfileButtonPressed extends LandingNavigationEvent {
  const LandingNavigationProfileButtonPressed();
}

class LandingNavigationProfileBackButtonPressed extends LandingNavigationEvent {
  const LandingNavigationProfileBackButtonPressed();
}

class LandingNavigationDonateButtonPressed extends LandingNavigationEvent {
  const LandingNavigationDonateButtonPressed();
}

class LandingNavigationAboutButtonPressed extends LandingNavigationEvent {
  const LandingNavigationAboutButtonPressed();
}
