// Project imports:
import 'package:web/app/models/user.dart';

/// Abstract class for Authentication events
abstract class AuthenticationEvent {}

/// A Sign in event
class AuthenticationSignInEvent extends AuthenticationEvent {}

/// A Sign out event
class AuthenticationSignOutEvent extends AuthenticationEvent {}

/// Try to sign in silently
class AuthenticationSilentSignInEvent extends AuthenticationEvent {}

/// New user event
class AuthenticationNewUserEvent extends AuthenticationEvent {
  /// send a new user event
  AuthenticationNewUserEvent(this.user);

  /// user
  User? user;
}
