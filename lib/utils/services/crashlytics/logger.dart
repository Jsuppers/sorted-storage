import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

class CrashReporter {
  void log({
    required dynamic exception,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    if (fatal) {
      await FirebaseCrashlytics.instance
          .recordError(exception, stackTrace, fatal: fatal);
      if (Platform.isAndroid) {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        exit(1);
      }
    } else {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace ?? StackTrace.fromString(exception.toString()),
      );
    }
  }
}
