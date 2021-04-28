// Package imports:
import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/models/user.dart' as usr;

/// This bloc handles the signing in and out of users
class AuthenticationBloc extends Bloc<AuthenticationEvent, usr.User?> {
  /// constructor creates the bloc and listens for user changes
  AuthenticationBloc() : super(null) {
    // attempt to sign in automatically
    add(AuthenticationSilentSignInEvent());

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? user) {
      add(AuthenticationNewUserEvent(user));
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      DriveApi.driveFileScope,
    ],
  );

  @override
  Stream<usr.User?> mapEventToState(AuthenticationEvent event) async* {
    if (event is AuthenticationNewUserEvent) {
      yield await _getCurrentUser(event.user);
      return;
    }
    switch (event.runtimeType) {
      case AuthenticationSignInEvent:
        if (await _googleSignIn.isSignedIn()) {
          yield state;
        } else {
          _googleSignIn.signIn();
        }
        break;
      case AuthenticationSilentSignInEvent:
        _googleSignIn.signInSilently();
        break;
      case AuthenticationSignOutEvent:
        _googleSignIn.signOut();
        break;
    }
  }

  Future<usr.User?> _getCurrentUser(GoogleSignInAccount? user) async {
    if (user == null) {
      return null;
    }
    return usr.User(
        displayName: user.displayName ?? '',
        email: user.email,
        photoUrl: user.photoUrl ?? '',
        headers: await user.authHeaders);
  }
}
