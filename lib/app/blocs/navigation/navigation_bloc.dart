import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// NavigationBloc handles all internal navigation between pages
class NavigationBloc extends Bloc<NavigationEvent, dynamic> {
  /// The constructor sets the NavigatorState used to navigate between routes
  NavigationBloc({@required GlobalKey<NavigatorState> navigatorKey})
      : super(null) {
    _navigatorKey = navigatorKey;
  }

  GlobalKey<NavigatorState> _navigatorKey;

  @override
  Stream<dynamic> mapEventToState(NavigationEvent event) async* {
    switch (event.runtimeType) {
      case NavigatorPopDialogEvent:
        _navigatorKey.currentState.pop('dialog');
        break;
      case NavigatorPopEvent:
        _navigatorKey.currentState.pop();
        break;
      default:
        if (!_navigatorKey.currentState.canPop()) {
          _navigatorKey.currentState.pushNamed(event.route);
        } else {
          _navigatorKey.currentState.pushReplacementNamed(event.route);
        }
        break;
    }
  }
}
