import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/models/user.dart' as usr;

/// This bloc handles the signing in and out of users
class AuthenticationBloc extends Bloc<AuthenticationEvent, usr.User> {
  /// constructor creates the bloc and listens for user changes
  AuthenticationBloc() : super(null) {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount user) {
      add(AuthenticationNewUserEvent(user));
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      DriveApi.DriveFileScope,
    ],
  );

  @override
  Stream<usr.User> mapEventToState(AuthenticationEvent event) async* {
    if (event is AuthenticationNewUserEvent) {
      yield await _getCurrentUser(event.user);
      return;
    }
    switch (event.runtimeType) {
      case AuthenticationSignInEvent:
        _googleSignIn.signIn();
        break;
      case AuthenticationSilentSignInEvent:
        _googleSignIn.signInSilently();
        break;
      case AuthenticationSignOutEvent:
        _googleSignIn.signOut();
        break;
    }
  }

  Future<usr.User> _getCurrentUser(GoogleSignInAccount user) async {
    if (user == null) {
      return null;
    }
    return usr.User(
        balance: 0,
        displayName: user.displayName,
        id: user.id,
        email: user.email,
        photoUrl: user.photoUrl,
        headers: await user.authHeaders);
  }
}
