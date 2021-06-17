/// Namespace for app spacings
abstract class AppSpacings {
  /// Current Scale factor of screen
  static late double _scaleFactor;

  /// Sets the scale factor used to calculate spacings
  static set scaleFactor(double scaleFactor) {
    _scaleFactor = scaleFactor;
  }

  /// Spacing with value of 4 * `scaleFactor`
  static double get four => 4 * _scaleFactor;

  /// Spacing with value of 6 * `scaleFactor`
  static double get six => 6 * _scaleFactor;

  /// Spacing with value of 8 * `scaleFactor`
  static double get eight => 8 * _scaleFactor;

  /// Spacing with value of 12 * `scaleFactor`
  static double get twelve => 12 * _scaleFactor;

  /// Spacing with value of 14 * `scaleFactor`
  static double get fourteen => 14 * _scaleFactor;

  /// Spacing with value of 16 * `scaleFactor`
  static double get sixteen => 16 * _scaleFactor;

  /// Spacing with value of 18 * `scaleFactor`
  static double get eighteen => 18 * _scaleFactor;

  /// Spacing with value of 24 * `scaleFactor`
  static double get twentyFour => 24 * _scaleFactor;

  /// Spacing with value of 32 * `scaleFactor`
  static double get thirtyTwo => 32 * _scaleFactor;

  /// Spacing with value of 48 * `scaleFactor`
  static double get fortyEight => 48 * _scaleFactor;
}
