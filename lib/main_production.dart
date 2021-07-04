// Dart imports:
import 'dart:async';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import 'package:sorted_storage/app/app.dart';
import 'package:sorted_storage/app/app_bloc_observer.dart';
import 'package:sorted_storage/utils/services/authentication/repositories/repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  await Hive.initFlutter();
  await Hive.openBox('themes');
  final _authenticationRepository = AuthenticationRepository();

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  await FirebaseCrashlytics.instance
      .setUserIdentifier(_authenticationRepository.uid ?? 'Unregistered user');

  runZonedGuarded(
    () => runApp(App(authenticationRepository: _authenticationRepository)),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
