part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLogoutSuccess extends ProfileState{
  const ProfileLogoutSuccess();
}

class ProfileDialogCloseSuccess extends ProfileState{
  const ProfileDialogCloseSuccess();
}