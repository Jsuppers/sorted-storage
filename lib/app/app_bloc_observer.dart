// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sorted_storage/utils/services/crashlytics/crashlytics.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (!kReleaseMode) {
      log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    } else {
      CrashReporter().log(exception: error, stackTrace: stackTrace);
    }
    super.onError(bloc, error, stackTrace);
  }
}
