// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc/bloc.dart';

part 'landing_navigation_event.dart';
part 'landing_navigation_state.dart';

class LandingNavigationBloc
    extends Bloc<LandingNavigationEvent, LandingNavigationState> {
  LandingNavigationBloc() : super(const LandingNavigationPageChangeSuccess(0));

  @override
  Stream<LandingNavigationState> mapEventToState(
    LandingNavigationEvent event,
  ) async* {
    if (event is LandingNavigationFloatingActionButtonPressed) {
      yield LandingNavigationFloatingActionButtonToggledInProgress();
    } else if (event is LandingNavigationHomeButtonPressed ||
        event is LandingNavigationProfileBackButtonPressed) {
      yield const LandingNavigationPageChangeSuccess(0);
    } else if (event is LandingNavigationProfileButtonPressed) {
      yield const LandingNavigationPageChangeSuccess(1);
    } else if (event is LandingNavigationDonateButtonPressed) {
      yield const LandingNavigationOpenDonationPageInProgress();
    } else if (event is LandingNavigationAboutButtonPressed) {
      yield const LandingNavigationPageChangeSuccess(2);
    }
  }
}
