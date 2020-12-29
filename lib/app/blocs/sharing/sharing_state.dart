/// abstract class for the sharing state
abstract class SharingState {
  /// constructor which sets the message
  SharingState(this.errorMessage);

  /// error message
  final String errorMessage;
}

/// story is shared
class SharingSharedState extends SharingState {
  /// constructor which allows setting the error message
  SharingSharedState({String errorMessage}) : super(errorMessage);
}

/// story is not shared
class SharingNotSharedState extends SharingState {
  /// constructor which allows setting the error message
  SharingNotSharedState({String errorMessage}) : super(errorMessage);
}
