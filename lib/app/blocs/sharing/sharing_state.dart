abstract class SharingState {
  final String message;
  SharingState(this.message);
}

class SharingSharedState extends SharingState {
  SharingSharedState({String message}) : super(message);
}
class SharingNotSharedState extends SharingState {
  SharingNotSharedState({String message}) : super(message);
}
