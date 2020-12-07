import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';

class NavigationBloc extends Bloc<NavigationEvent, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationBloc({this.navigatorKey}) : super(0);

  @override
  Stream<dynamic> mapEventToState(NavigationEvent event) async* {
    switch (event.runtimeType) {
      case NavigatorPopEvent:
        navigatorKey.currentState.pop();
        break;
      case NavigateToChangeProfileEvent:
        URLService.openURL("https://myaccount.google.com/personal-info");
        break;
      case NavigateToUpgradeEvent:
        URLService.openURL("https://one.google.com/about/plans");
        break;
      case NavigateToDonate:
        URLService.openURL(Constants.DONATE_URL);
        break;
      default:
        navigatorKey.currentState.pushNamed(event.route);
        break;
    }
  }
}
