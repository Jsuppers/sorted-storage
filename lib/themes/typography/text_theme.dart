// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/themes/typography/typography.dart';

abstract class StorageTextTheme {
  static const double _smallScaleFactor = ScreenScaleFactors.smallScaleFactor;
  static const double _mediumScaleFactor = ScreenScaleFactors.mediumScaleFactor;
  static const double _largeScaleFactor = ScreenScaleFactors.largeScaleFactor;
  static const double _xLargeScaleFactor = ScreenScaleFactors.xLargeScaleFactor;

  static TextTheme get _textTheme {
    return TextTheme(
      headline1: StorageTextStyle.headline1,
      headline2: StorageTextStyle.headline2,
      headline3: StorageTextStyle.headline3,
      headline4: StorageTextStyle.headline4,
      headline5: StorageTextStyle.headline5,
      headline6: StorageTextStyle.headline6,
      subtitle1: StorageTextStyle.subtitle1,
      subtitle2: StorageTextStyle.subtitle2,
      bodyText1: StorageTextStyle.bodyText1,
      bodyText2: StorageTextStyle.bodyText2,
      caption: StorageTextStyle.caption,
      overline: StorageTextStyle.overline,
      button: StorageTextStyle.button,
    );
  }

  static TextTheme get smallTextTheme {
    return TextTheme(
      headline1: StorageTextStyle.headline1.copyWith(
        fontSize: _textTheme.headline1!.fontSize! * _smallScaleFactor,
      ),
      headline2: StorageTextStyle.headline2.copyWith(
        fontSize: _textTheme.headline2!.fontSize! * _smallScaleFactor,
      ),
      headline3: StorageTextStyle.headline3.copyWith(
        fontSize: _textTheme.headline3!.fontSize! * _smallScaleFactor,
      ),
      headline4: StorageTextStyle.headline4.copyWith(
        fontSize: _textTheme.headline4!.fontSize! * _smallScaleFactor,
      ),
      headline5: StorageTextStyle.headline5.copyWith(
        fontSize: _textTheme.headline5!.fontSize! * _smallScaleFactor,
      ),
      headline6: StorageTextStyle.headline6.copyWith(
        fontSize: _textTheme.headline6!.fontSize! * _smallScaleFactor,
      ),
      subtitle1: StorageTextStyle.subtitle1.copyWith(
        fontSize: _textTheme.subtitle1!.fontSize! * _smallScaleFactor,
      ),
      subtitle2: StorageTextStyle.subtitle2.copyWith(
        fontSize: _textTheme.subtitle2!.fontSize! * _smallScaleFactor,
      ),
      bodyText1: StorageTextStyle.bodyText1.copyWith(
        fontSize: _textTheme.bodyText1!.fontSize! * _smallScaleFactor,
      ),
      bodyText2: StorageTextStyle.bodyText2.copyWith(
        fontSize: _textTheme.bodyText2!.fontSize! * _smallScaleFactor,
      ),
      caption: StorageTextStyle.caption.copyWith(
        fontSize: _textTheme.caption!.fontSize! * _smallScaleFactor,
      ),
      overline: StorageTextStyle.overline.copyWith(
        fontSize: _textTheme.overline!.fontSize! * _smallScaleFactor,
      ),
      button: StorageTextStyle.button.copyWith(
        fontSize: _textTheme.button!.fontSize! * _smallScaleFactor,
      ),
    );
  }

  static TextTheme get mediumTextTheme {
    return TextTheme(
      headline1: StorageTextStyle.headline1.copyWith(
        fontSize: _textTheme.headline1!.fontSize! * _mediumScaleFactor,
      ),
      headline2: StorageTextStyle.headline2.copyWith(
        fontSize: _textTheme.headline2!.fontSize! * _mediumScaleFactor,
      ),
      headline3: StorageTextStyle.headline3.copyWith(
        fontSize: _textTheme.headline3!.fontSize! * _mediumScaleFactor,
      ),
      headline4: StorageTextStyle.headline4.copyWith(
        fontSize: _textTheme.headline4!.fontSize! * _mediumScaleFactor,
      ),
      headline5: StorageTextStyle.headline5.copyWith(
        fontSize: _textTheme.headline5!.fontSize! * _mediumScaleFactor,
      ),
      headline6: StorageTextStyle.headline6.copyWith(
        fontSize: _textTheme.headline6!.fontSize! * _mediumScaleFactor,
      ),
      subtitle1: StorageTextStyle.subtitle1.copyWith(
        fontSize: _textTheme.subtitle1!.fontSize! * _mediumScaleFactor,
      ),
      subtitle2: StorageTextStyle.subtitle2.copyWith(
        fontSize: _textTheme.subtitle2!.fontSize! * _mediumScaleFactor,
      ),
      bodyText1: StorageTextStyle.bodyText1.copyWith(
        fontSize: _textTheme.bodyText1!.fontSize! * _mediumScaleFactor,
      ),
      bodyText2: StorageTextStyle.bodyText2.copyWith(
        fontSize: _textTheme.bodyText2!.fontSize! * _mediumScaleFactor,
      ),
      caption: StorageTextStyle.caption.copyWith(
        fontSize: _textTheme.caption!.fontSize! * _mediumScaleFactor,
      ),
      overline: StorageTextStyle.overline.copyWith(
        fontSize: _textTheme.overline!.fontSize! * _mediumScaleFactor,
      ),
      button: StorageTextStyle.button.copyWith(
        fontSize: _textTheme.button!.fontSize! * _mediumScaleFactor,
      ),
    );
  }

  static TextTheme get largeTextTheme {
    return TextTheme(
      headline1: StorageTextStyle.headline1.copyWith(
        fontSize: _textTheme.headline1!.fontSize! * _largeScaleFactor,
      ),
      headline2: StorageTextStyle.headline2.copyWith(
        fontSize: _textTheme.headline2!.fontSize! * _largeScaleFactor,
      ),
      headline3: StorageTextStyle.headline3.copyWith(
        fontSize: _textTheme.headline3!.fontSize! * _largeScaleFactor,
      ),
      headline4: StorageTextStyle.headline4.copyWith(
        fontSize: _textTheme.headline4!.fontSize! * _largeScaleFactor,
      ),
      headline5: StorageTextStyle.headline5.copyWith(
        fontSize: _textTheme.headline5!.fontSize! * _largeScaleFactor,
      ),
      headline6: StorageTextStyle.headline6.copyWith(
        fontSize: _textTheme.headline6!.fontSize! * _largeScaleFactor,
      ),
      subtitle1: StorageTextStyle.subtitle1.copyWith(
        fontSize: _textTheme.subtitle1!.fontSize! * _largeScaleFactor,
      ),
      subtitle2: StorageTextStyle.subtitle2.copyWith(
        fontSize: _textTheme.subtitle2!.fontSize! * _largeScaleFactor,
      ),
      bodyText1: StorageTextStyle.bodyText1.copyWith(
        fontSize: _textTheme.bodyText1!.fontSize! * _largeScaleFactor,
      ),
      bodyText2: StorageTextStyle.bodyText2.copyWith(
        fontSize: _textTheme.bodyText2!.fontSize! * _largeScaleFactor,
      ),
      caption: StorageTextStyle.caption.copyWith(
        fontSize: _textTheme.caption!.fontSize! * _largeScaleFactor,
      ),
      overline: StorageTextStyle.overline.copyWith(
        fontSize: _textTheme.overline!.fontSize! * _largeScaleFactor,
      ),
      button: StorageTextStyle.button.copyWith(
        fontSize: _textTheme.button!.fontSize! * _largeScaleFactor,
      ),
    );
  }

  static TextTheme get xLargeTextTheme {
    return TextTheme(
      headline1: StorageTextStyle.headline1.copyWith(
        fontSize: _textTheme.headline1!.fontSize! * _xLargeScaleFactor,
      ),
      headline2: StorageTextStyle.headline2.copyWith(
        fontSize: _textTheme.headline2!.fontSize! * _xLargeScaleFactor,
      ),
      headline3: StorageTextStyle.headline3.copyWith(
        fontSize: _textTheme.headline3!.fontSize! * _xLargeScaleFactor,
      ),
      headline4: StorageTextStyle.headline4.copyWith(
        fontSize: _textTheme.headline4!.fontSize! * _xLargeScaleFactor,
      ),
      headline5: StorageTextStyle.headline5.copyWith(
        fontSize: _textTheme.headline5!.fontSize! * _xLargeScaleFactor,
      ),
      headline6: StorageTextStyle.headline6.copyWith(
        fontSize: _textTheme.headline6!.fontSize! * _xLargeScaleFactor,
      ),
      subtitle1: StorageTextStyle.subtitle1.copyWith(
        fontSize: _textTheme.subtitle1!.fontSize! * _xLargeScaleFactor,
      ),
      subtitle2: StorageTextStyle.subtitle2.copyWith(
        fontSize: _textTheme.subtitle2!.fontSize! * _xLargeScaleFactor,
      ),
      bodyText1: StorageTextStyle.bodyText1.copyWith(
        fontSize: _textTheme.bodyText1!.fontSize! * _xLargeScaleFactor,
      ),
      bodyText2: StorageTextStyle.bodyText2.copyWith(
        fontSize: _textTheme.bodyText2!.fontSize! * _xLargeScaleFactor,
      ),
      caption: StorageTextStyle.caption.copyWith(
        fontSize: _textTheme.caption!.fontSize! * _xLargeScaleFactor,
      ),
      overline: StorageTextStyle.overline.copyWith(
        fontSize: _textTheme.overline!.fontSize! * _xLargeScaleFactor,
      ),
      button: StorageTextStyle.button.copyWith(
        fontSize: _textTheme.button!.fontSize! * _xLargeScaleFactor,
      ),
    );
  }
}
