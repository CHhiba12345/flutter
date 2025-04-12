import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Open Food Facts';
  static const String searchHint = 'Search for a product...';

  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets symmetricPadding = EdgeInsets.symmetric(horizontal: 16);

  static const Color scaffoldBackgroundColor = Color(0xFFFFF9F9);

  static const List<Color> titleGradient = [
    Color(0xFF1E201E),
    Color(0xFFEF1C58),
    Color(0xFF253921)
  ];

  static OutlineInputBorder searchInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
    borderSide: BorderSide.none,
  );
}