import 'package:flutter/material.dart';

final ThemeData myThemeData = _buildTheme();

final BoxDecoration myBackgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [myThemeData.primaryColor, myThemeData.accentColor],
  ),
);

Color _darkPrimary = const Color(0xFF293040);
Color _lightPrimary = const Color(0xFFBDBDBD);

ThemeData _buildTheme() {
  return ThemeData(
    primarySwatch: MaterialColor(_darkPrimary.value, const <int, Color>{
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
    }),
    dialogBackgroundColor: _lightPrimary,
    toggleableActiveColor: _darkPrimary,
    dialogTheme: DialogTheme(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.normal,
          color: _darkPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 12.0,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.normal,
          color: _darkPrimary,
        )),
    primaryColor: const Color(0xFFffe6ff),
    primaryColorDark: _darkPrimary,
    primaryColorLight: _lightPrimary,
    dividerColor: const Color(0xFFBDBDBD),
    accentColor: const Color(0xFFccddff),
    fontFamily: 'OpenSans',
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
        color: _darkPrimary,
      ),
      headline2: TextStyle(
        fontSize: 28.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkPrimary,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkPrimary,
      ),
      headline4: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        color: _darkPrimary,
      ),
      button: const TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      headline5: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: _darkPrimary,
      ),
      headline6: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        color: _darkPrimary,
      ),
      bodyText1: TextStyle(
        fontSize: 14.0,
        fontFamily: 'OpenSans',
        color: _darkPrimary,
      ),
      bodyText2: TextStyle(
        fontSize: 14.0,
        fontFamily: 'OpenSans',
        color: _darkPrimary,
      ),
    ),
  );
}
