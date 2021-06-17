// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'font_weights.dart';

/// Storage Text Style Definitions
class StorageTextStyle {
  static const _baseTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: StorageFontWeight.regular,
  );

  /// Headline 1 Text Style
  static TextStyle get headline1 {
    return _baseTextStyle.copyWith(
      fontSize: 48,
      fontWeight: StorageFontWeight.regular,
    );
  }

  /// Headline 2 Text Style
  static TextStyle get headline2 {
    return _baseTextStyle.copyWith(
      fontSize: 32,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.2,
    );
  }

  /// Headline 3 Text Style
  static TextStyle get headline3 {
    return _baseTextStyle.copyWith(
      fontSize: 28,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.2,
    );
  }

  /// Headline 4 Text Style
  static TextStyle get headline4 {
    return _baseTextStyle.copyWith(
      fontSize: 24,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.2,
    );
  }

  /// Headline 5 Text Style
  static TextStyle get headline5 {
    return _baseTextStyle.copyWith(
      fontSize: 24,
      fontWeight: StorageFontWeight.regular,
    );
  }

  /// Headline 6 Text Style
  static TextStyle get headline6 {
    return _baseTextStyle.copyWith(
      fontSize: 20,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.25,
    );
  }

  /// Subtitle 1 Text Style
  static TextStyle get subtitle1 {
    return _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.2,
    );
  }

  /// Subtitle 2 Text Style
  static TextStyle get subtitle2 {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 0.15,
    );
  }

  /// Body Text 1 Text Style
  static TextStyle get bodyText1 {
    return _baseTextStyle.copyWith(
      fontSize: 20,
      fontWeight: StorageFontWeight.regular,
      letterSpacing: 0.25,
    );
  }

  /// Body Text 2 Text Style
  static TextStyle get bodyText2 {
    return _baseTextStyle.copyWith(
      fontSize: 18,
      fontWeight: StorageFontWeight.regular,
      letterSpacing: 0.15,
    );
  }

  /// Button Text Style
  static TextStyle get button {
    return _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: StorageFontWeight.medium,
      letterSpacing: 1,
    );
  }

  /// Caption Text Style
  static TextStyle get caption {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: StorageFontWeight.regular,
      letterSpacing: 0.1,
    );
  }

  /// Overline Text Style
  static TextStyle get overline {
    return _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: StorageFontWeight.regular,
      letterSpacing: 1.5,
    );
  }
}
