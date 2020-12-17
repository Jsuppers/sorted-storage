import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';

// ignore: must_be_immutable
class MockGlobalKey extends Mock implements GlobalKey<NavigatorState> {
  @override
  NavigatorState currentState;
}

class MockNavigatorState extends NavigatorState {
  MockNavigatorState(
      {this.popCallback,
        this.canPopCallback,
        this.pushNamedCallback,
        this.pushReplacementNamedCallback});

  Function popCallback;
  Function canPopCallback;
  Function(String) pushNamedCallback;
  Function(String) pushReplacementNamedCallback;

  @override
  void pop<T extends Object>([T result]) {
    popCallback();
  }

  @override
  bool canPop() {
    return canPopCallback() as bool;
  }

  @override
  // ignore: missing_return
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) {
    pushNamedCallback(routeName);
  }

  @override
  // ignore: missing_return
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO result,
      Object arguments}) {
    pushReplacementNamedCallback(routeName);
  }
}

main() {
  group('NavigationBloc', () {
    MockGlobalKey mockGlobalKey;
    bool calledPop;
    List<String> pushedNames = [];
    List<String> pushReplacementNamed = [];

    blocTest('Given a NavigationBloc when it is initialized return nothing',
        build: () => NavigationBloc(),
        expect: [],
        verify: (bloc) {
          expect(bloc.state, null);
        });

    blocTest(
        'Given a pop event when a NavigatorPopEvent is called then pop event is called',
        build: () {
          calledPop = false;
          mockGlobalKey = MockGlobalKey();
          mockGlobalKey.currentState = MockNavigatorState(popCallback: () {
            calledPop = true;
          });
          return NavigationBloc(navigatorKey: mockGlobalKey);
        },
        act: (bloc) => bloc.add(NavigatorPopEvent()),
        expect: [],
        verify: (bloc) {
          expect(calledPop, true);
        });

    blocTest(
        'Given a navigate event when we cannot pop then a pushedName event is called',
        build: () {
          mockGlobalKey = MockGlobalKey();
          mockGlobalKey.currentState = MockNavigatorState(canPopCallback: () {
            return false;
          }, pushNamedCallback: (value) {
            pushedNames.add(value);
          });
          return NavigationBloc(navigatorKey: mockGlobalKey);
        },
        act: (bloc) {
          bloc.add(NavigateToHomeEvent());
          bloc.add(NavigateToLoginEvent());
          bloc.add(NavigateToMediaEvent());
          bloc.add(NavigateToDocumentsEvent());
          bloc.add(NavigateToTermsEvent());
          bloc.add(NavigateToPrivacyEvent());
        },
        expect: [],
        verify: (bloc) {
          expect(pushedNames, [
            HomePage.route,
            LoginPage.route,
            MediaPage.route,
            DocumentsPage.route,
            TermsPage.route,
            PolicyPage.route
          ]);
        });

    blocTest(
        'Given a navigate event when we can pop then a pushedReplacementName event is called',
        build: () {
          mockGlobalKey = MockGlobalKey();
          mockGlobalKey.currentState = MockNavigatorState(canPopCallback: () {
            return true;
          }, pushReplacementNamedCallback: (value) {
            pushReplacementNamed.add(value);
          });
          return NavigationBloc(navigatorKey: mockGlobalKey);
        },
        act: (bloc) {
          bloc.add(NavigateToHomeEvent());
          bloc.add(NavigateToLoginEvent());
          bloc.add(NavigateToMediaEvent());
          bloc.add(NavigateToDocumentsEvent());
          bloc.add(NavigateToTermsEvent());
          bloc.add(NavigateToPrivacyEvent());
        },
        expect: [],
        verify: (bloc) {
          expect(pushReplacementNamed, [
            HomePage.route,
            LoginPage.route,
            MediaPage.route,
            DocumentsPage.route,
            TermsPage.route,
            PolicyPage.route
          ]);
        });
  });
}
