import 'package:flutter/material.dart';

class AppColors {
  // Couleurs de base
  static const Color primary = Color(0xFF2C5728);
  static const Color primaryLight = Color(0xFF7FD3F8);
  static const Color primaryDark = Color(0xFF0095D9);

  static const Color secondary = Color(0xFF3E6839);
  static const Color secondaryLight = Color(0xFF4D82B3);

  static const Color background = Color(0xFFDADFDD);
  static const Color backgroundLight = Color(0xFFD6F9F1);

  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textWhite = Colors.white;

  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFDD6B20);
  static const Color info = Color(0xFF4299E1);

  // Dégradés prédéfinis
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryDark, primary],
    stops: [0.0, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    colors: [backgroundLight, background],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get buttonGradient => LinearGradient(
    colors: [primary, primaryLight],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get healthCardGradient => LinearGradient(
    colors: [Color(0xFFE6FFFA), Color(0xFFB2F5EA)],
    stops: [0.1, 0.9],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient get foodCardGradient => LinearGradient(
    colors: [Color(0xFFFFF5F5), Color(0xFFFFE5E5)],
    stops: [0.1, 0.9],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dégradés dynamiques
  static LinearGradient createCustomGradient({
    required List<Color> colors,
    List<double>? stops,
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }
}