// Dart imports:
import 'dart:async';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import 'package:sorted_storage/app/app.dart';
import 'package:sorted_storage/app/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  await Hive.initFlutter();
  await Hive.openBox('themes');

  runZonedGuarded(
    () => runApp(const App()),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
