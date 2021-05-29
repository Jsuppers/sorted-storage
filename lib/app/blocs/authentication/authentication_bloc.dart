// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/cloud_provider/google/google_drive.dart';

/// This bloc handles the signing in and out of users
class AuthenticationBloc extends Bloc<AuthenticationEvent, User?> {
  /// constructor creates the bloc and listens for user changes
  AuthenticationBloc({required this.storage}) : super(null) {
    // attempt to sign in automatically
    add(AuthenticationSilentSignInEvent());

    storage.userChange().listen((User? user) async {
      add(AuthenticationNewUserEvent(user));
    });
  }

  GoogleDrive storage;

  @override
  Stream<User?> mapEventToState(AuthenticationEvent event) async* {
    if (event is AuthenticationNewUserEvent) {
      yield event.user;
      return;
    }
    switch (event.runtimeType) {
      case AuthenticationSignInEvent:
        if (await storage.isSignedIn()) {
          yield state;
        } else {
          storage.signIn();
        }
        break;
      case AuthenticationSilentSignInEvent:
        storage.signInSilently();
        break;
      case AuthenticationSignOutEvent:
        storage.signOut();
        break;
    }
  }
}
