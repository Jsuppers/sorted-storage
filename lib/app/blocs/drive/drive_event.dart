import 'package:web/app/models/user.dart' as usr;

/// abstract class for drive events
abstract class DriveEvent {}

/// Initial event which sets the user
class InitialDriveEvent extends DriveEvent {
  /// constructor which optionally sets the user
  InitialDriveEvent({this.user});

  /// the user
  final usr.User? user;
}
