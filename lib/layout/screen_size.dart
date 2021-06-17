/// Types of screen sizes
enum ScreenSize {
  small,
  medium,
  large,
  xLarge,
}

/// Namespace for screen size
abstract class DeviceScreenSize {
  static late ScreenSize screenSize;
}
