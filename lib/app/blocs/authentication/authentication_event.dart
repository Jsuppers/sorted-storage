import 'package:google_sign_in/google_sign_in.dart';

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
  GoogleSignInAccount user;
}
