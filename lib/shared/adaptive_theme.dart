import 'package:flutter/material.dart';

final ThemeData androidTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepPurple,
  fontFamily: 'Oswald',
  buttonColor: Colors.deepPurple,
);

final ThemeData iOSTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.grey,
  accentColor: Colors.blue,
  fontFamily: 'Oswald',
  buttonColor: Colors.deepPurple,
);

ThemeData getAdaptiveThemeData(context){
  return Theme.of(context).platform == TargetPlatform.android ? androidTheme : iOSTheme;
}