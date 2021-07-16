part of 'landing_navigation_bloc.dart';

abstract class LandingNavigationState {
  const LandingNavigationState();
}

class LandingNavigationFloatingActionButtonToggledInProgress
    extends LandingNavigationState {
  const LandingNavigationFloatingActionButtonToggledInProgress();
}

class LandingNavigationPageChangeSuccess extends LandingNavigationState {
  const LandingNavigationPageChangeSuccess(this.index);
  final int index;
}

class LandingNavigationOpenDonationPageInProgress
    extends LandingNavigationState {
  const LandingNavigationOpenDonationPageInProgress();
}
