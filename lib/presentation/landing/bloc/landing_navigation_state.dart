part of 'landing_navigation_bloc.dart';

abstract class LandingNavigationState {
  const LandingNavigationState();
}

// LandingNavigationFloatingActionButtonToggledInProgress state
// should always trigger ui changes so this can not be constant
class LandingNavigationFloatingActionButtonToggledInProgress
    extends LandingNavigationState {}

class LandingNavigationPageChangeSuccess extends LandingNavigationState {
  const LandingNavigationPageChangeSuccess(this.index);
  final int index;
}

class LandingNavigationOpenDonationPageInProgress
    extends LandingNavigationState {
  const LandingNavigationOpenDonationPageInProgress();
}
