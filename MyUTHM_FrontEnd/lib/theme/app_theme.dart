import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  AppTheme._();


  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    extensions: const <ThemeExtension<dynamic>>[
      lightColors,
    ],

    scaffoldBackgroundColor: lightColors.background,
  );


  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    extensions: const <ThemeExtension<dynamic>>[
      darkColors,
    ],
    scaffoldBackgroundColor: darkColors.background,
  );
}
