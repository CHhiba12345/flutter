import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle headlineLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

// Ajoutez d'autres styles au besoin
}