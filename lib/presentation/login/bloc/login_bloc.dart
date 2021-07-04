// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:sorted_storage/utils/services/authentication/authentication.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.authenticationRepository) : super(const LoginInitial());
  final AuthenticationRepository authenticationRepository;

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginGoogleAuthButtonPressed) {
      yield await _mapLoginGoogleAuthButtonPressedToState();
    }
  }

  Future<LoginState> _mapLoginGoogleAuthButtonPressedToState() async {
    try {
      await authenticationRepository.signInWithGoogle();
      return const LoginSuccess();
    } on AuthException catch (e) {
      return LoginFailure(e.body);
    }
  }
}
