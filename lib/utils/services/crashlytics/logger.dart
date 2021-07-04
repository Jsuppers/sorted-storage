// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashReporter {
  void log({
    required dynamic exception,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace ?? StackTrace.fromString(exception.toString()),
      fatal: fatal,
    );
  }
}
