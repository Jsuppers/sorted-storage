part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLogoutButtonPressed extends ProfileEvent {
  const ProfileLogoutButtonPressed();
}

class ProfileCloseButtonPressed extends ProfileEvent {
  const ProfileCloseButtonPressed();
}
