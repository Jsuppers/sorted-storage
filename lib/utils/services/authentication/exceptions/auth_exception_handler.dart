// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:sorted_storage/utils/services/authentication/exceptions/auth_exception.dart';

class AuthExceptionHandler {
  const AuthExceptionHandler();

  /// Maps `FirebaseAuthException` errors to their respective `AuthException`
  void mapAndThrow(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-disabled':
        throw AccountDisabledException(stackTrace: error.stackTrace);
      case 'too-many-requests':
      case 'operation-not-allowed':
        throw TooManyRequestsException(stackTrace: error.stackTrace);
      case 'network-request-failed':
        throw FirebaseNoNetworkException(stackTrace: error.stackTrace);
      default:
        throw UnknownAuthException(stackTrace: error.stackTrace);
    }
  }
}
