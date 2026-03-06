import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color lightPink = Color(0xFFFCE4EC);
  static const Color darkPink = Color(0xFF880E4F);
  static const Color loveRed = Color(0xFFFF1744);
  static const Color nightBackground = Color(0xFF2A0815);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        brightness: Brightness.light,
        primary: primaryPink,
        secondary: loveRed,
        background: lightPink,
      ),
      scaffoldBackgroundColor: Colors.transparent, // For custom gradients
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        brightness: Brightness.dark,
        primary: primaryPink,
        secondary: loveRed,
        background: nightBackground,
      ),
      scaffoldBackgroundColor: Colors.transparent, // For custom gradients
      fontFamily: 'Roboto',
    );
  }
}
