// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' hide User;

class AuthenticationRepository {
  /// Instance of firebase auth
  final _firebaseAuth = FirebaseAuth.instance;

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
    } on Exception catch (_) {
      // TODO: Add error and exception handling
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
