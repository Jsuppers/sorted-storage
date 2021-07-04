// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' hide User;

// Project imports:
import 'package:sorted_storage/utils/services/authentication/authentication.dart';
import 'package:sorted_storage/utils/services/crashlytics/crashlytics.dart';

class AuthenticationRepository {
  AuthenticationRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Instance of firebase auth
  late final FirebaseAuth _firebaseAuth;

  /// Instance of auth exception handler
  final _exceptionHandler = const AuthExceptionHandler();

  /// Returns a Stream of the user's current authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Authenticates a user by linking his google account
  Future<void> signInWithGoogle() async {
    try {
      final _googleUser = await GoogleSignIn(
        scopes: <String>[
          DriveApi.driveFileScope,
        ],
      ).signIn();
      if (_googleUser != null) {
        final _googleAuth = await _googleUser.authentication;

        final _authCredential = GoogleAuthProvider.credential(
          accessToken: _googleAuth.accessToken,
          idToken: _googleAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(_authCredential);
      }
    } on PlatformException catch (e) {
      CrashReporter().log(
        exception: e,
        stackTrace: StackTrace.fromString(e.stacktrace!),
        fatal: true,
      );
    } on FirebaseAuthException catch (e) {
      _exceptionHandler.mapAndThrow(e);
    }
  }

  /// Signs out the authenticated user
  Future<void> signOut() async => await _firebaseAuth.signOut();

  /// Returns the uid of the authenticated user
  String? get uid => _firebaseAuth.currentUser?.uid;

  /// Returns the username of the authenticated user
  String? get username => _firebaseAuth.currentUser?.displayName;

  /// Returns the email of the authenticated user
  String? get email => _firebaseAuth.currentUser?.email;

  /// Returns a link to the profile picture of an authenticated user
  String? get photoUrl => _firebaseAuth.currentUser?.photoURL;
}
