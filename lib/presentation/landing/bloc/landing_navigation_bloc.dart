// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/repositories/repositories.dart';

part 'landing_navigation_event.dart';

class LandingNavigationBloc extends Bloc<LandingNavigationEvent, int> {
  LandingNavigationBloc(this.landingFabRepository) : super(0);
  final LandingFabRepository landingFabRepository;

  @override
  Stream<int> mapEventToState(
    LandingNavigationEvent event,
  ) async* {
    if (event is LandingNavigationFloatingActionButtonPressed) {
      landingFabRepository.toggleButton(event.context);
    } else if (event is LandingNavigationHomeButtonPressed) {
      landingFabRepository.hideButtons();
      yield 0;
    } else if (event is LandingNavigationProfileButtonPressed) {
      landingFabRepository.hideButtons();
      yield 1;
    } else if (event is LandingNavigationDonateButtonPressed) {
    } else if (event is LandingNavigationAboutButtonPressed) {
      yield 2;
    }
  }
}
