import 'package:flutter/material.dart';

class MyTheme {
  static const Color accentColor = Color(0xFFccddff);
}

final ThemeData myThemeData = _buildTheme();

final BoxDecoration myBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [myThemeData.primaryColor, myThemeData.accentColor],
));

Color _darkText = Color(0xFF293040);
Color _lightText = Color(0xFFFFFFFF);

// Theme designed using https://www.materialpalette.com/orange/deep-orange
Color _primary = Color(0xFFffe6ff);
Color _darkPrimary = Color(0xFF293040);
Color _lightPrimary = Color(0xFFBDBDBD);
Color _divider = Color(0xFFBDBDBD);
Color _accent = Color(0xFFccddff);

Map<int, Color> colorCodes = {
  50: Color.fromRGBO(41, 48, 64, .1),
  100: Color.fromRGBO(41, 48, 64, .2),
  200: Color.fromRGBO(41, 48, 64, .3),
  300: Color.fromRGBO(41, 48, 64, .4),
  400: Color.fromRGBO(41, 48, 64, .5),
  500: Color.fromRGBO(41, 48, 64, .6),
  600: Color.fromRGBO(41, 48, 64, .7),
  700: Color.fromRGBO(41, 48, 64, .8),
  800: Color.fromRGBO(41, 48, 64, .9),
  900: Color.fromRGBO(41, 48, 64, 1),
};
// Green color code: FF93cd48
MaterialColor customColor = MaterialColor(0xFF293040, colorCodes);

ThemeData _buildTheme() {
  return ThemeData(
    primarySwatch: customColor,
    dialogBackgroundColor: _lightPrimary,
    toggleableActiveColor: _darkPrimary,
    textSelectionColor: _accent,
    textSelectionHandleColor: _accent,
    useTextSelectionTheme: false,
    dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.normal,
          color: _darkText,
        ),
        contentTextStyle: TextStyle(
          fontSize: 12.0,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.normal,
          color: _darkText,
        )),
    primaryColor: _primary,
    primaryColorDark: _darkPrimary,
    primaryColorLight: _lightPrimary,
    dividerColor: _divider,
    accentColor: _accent,
    fontFamily: "OpenSans",
    textTheme: TextTheme(
      caption: TextStyle(
        fontSize: 12.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.normal,
        color: _lightPrimary,
      ),
      headline1: TextStyle(
        fontSize: 42.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkText,
      ),
      headline2: TextStyle(
        fontSize: 28.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkText,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkText,
      ),
      headline4: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkText,
      ),
      button: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: _lightText,
      ),
      headline5: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: _darkText,
      ),
      headline6: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: _darkText,
      ),
      bodyText1:
          TextStyle(fontSize: 14.0, fontFamily: 'OpenSans', color: _darkText),
      bodyText2:
          TextStyle(fontSize: 14.0, fontFamily: 'OpenSans', color: _darkText),
    ),
  );
}
