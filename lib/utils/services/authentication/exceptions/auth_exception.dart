// Project imports:
import 'package:sorted_storage/utils/services/crashlytics/crashlytics.dart';

/// Base class of other exceptions that occur during firebase operations
class AuthException implements Exception {
  AuthException(
    this.type, {
    required this.body,
    required this.stackTrace,
    this.fatal,
  }) {
    CrashReporter().log(
      exception: type,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  final Object type;
  final String title = 'Error';
  final String body;
  final StackTrace? stackTrace;
  final bool? fatal;
}

/// Exception thrown when account is disabled
class AccountDisabledException extends AuthException {
  AccountDisabledException({required StackTrace? stackTrace})
      : super(
          AccountDisabledException,
          body: 'Account has been disabled.',
          stackTrace: stackTrace,
        );
}

/// Exception thrown when there are too many requests
/// sent to firebase in a short period of time
class TooManyRequestsException extends AuthException {
  TooManyRequestsException({required StackTrace? stackTrace})
      : super(
          TooManyRequestsException,
          body: 'Too many requests. Please try again later.',
          stackTrace: stackTrace,
        );
}

/// Exception thrown when there is no internet connection
class FirebaseNoNetworkException extends AuthException {
  FirebaseNoNetworkException({required StackTrace? stackTrace})
      : super(
          FirebaseNoNetworkException,
          body: 'No internet connection',
          stackTrace: stackTrace,
        );
}

/// Exception thrown when the exception that occurred is unknown
class UnknownAuthException extends AuthException {
  UnknownAuthException({required StackTrace? stackTrace})
      : super(
          UnknownAuthException,
          stackTrace: stackTrace,
          body: 'An unknown error has occurred. Please try again later',
          fatal: true,
        );
}
