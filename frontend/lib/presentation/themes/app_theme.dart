import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData light = ThemeData(
      scaffoldBackgroundColor: LightThemeColors.backgroundColor,
      primaryColor: LightThemeColors.primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          bodyLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      iconTheme: IconThemeData(color: Colors.black),
      fontFamily: "Inter",
      useMaterial3: true);

  static ThemeData dark = ThemeData(
      scaffoldBackgroundColor: DarkThemeColors.backgroundColor,
      primaryColor: DarkThemeColors.primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          bodyLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      iconTheme: IconThemeData(color: Colors.white),
      fontFamily: "Inter",
      useMaterial3: true);
}
