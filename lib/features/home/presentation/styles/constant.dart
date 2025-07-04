import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '';
  static const String searchHint = 'Search for a product...';

  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets symmetricPadding = EdgeInsets.symmetric(horizontal: 16);

  static const Color scaffoldBackgroundColor = Color(0xFFFFF9F9);

  static const List<Color> titleGradient = [
    Color(0xFFF6FCF6),
    Color(0xFFECE3E3),
    Color(0xFFF5ECEC)
  ];

  static OutlineInputBorder searchInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
    borderSide: BorderSide.none,
  );
}