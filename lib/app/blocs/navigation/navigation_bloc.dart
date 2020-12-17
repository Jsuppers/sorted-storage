import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationBloc({this.navigatorKey}) : super(null);

  @override
  Stream<dynamic> mapEventToState(NavigationEvent event) async* {
    switch (event.runtimeType) {
      case NavigatorPopEvent:
        navigatorKey.currentState.pop();
        break;
      default:
        if (!navigatorKey.currentState.canPop()) {
          navigatorKey.currentState.pushNamed(event.route);
        } else {
          navigatorKey.currentState.pushReplacementNamed(event.route);
        }
        break;
    }
  }
}
