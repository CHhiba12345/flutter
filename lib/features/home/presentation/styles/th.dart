import 'package:flutter/material.dart';

import 'constant.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF39EF56),
    scaffoldBackgroundColor: const Color(0xFFC7F6BF),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter Tight',
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBackground,
      border: AppConstants.searchInputBorder,
    ),
  );

  static const Color secondaryBackground = Color(0xFFEBEAF6);
  static const Color primaryDark = Color(0xFF48AF37);
  static const Color secondaryText = Color(0xFF48AF37);
}