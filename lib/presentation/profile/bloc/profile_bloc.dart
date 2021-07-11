import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileCloseButtonPressed) {
      yield const ProfileDialogCloseSuccess();
    } else if (event is ProfileLogoutButtonPressed) {
      yield const ProfileLogoutSuccess();
    }
  }
}
