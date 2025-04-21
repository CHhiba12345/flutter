import 'package:eye_volve/features/home/presentation/styles/th.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'constant.dart';

class HomeStyles {
  static InputDecoration searchInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: AppConstants.searchHint,
      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.secondaryText),
      filled: true,
      fillColor: AppTheme.secondaryBackground,
      border: AppConstants.searchInputBorder,
    );
  }

  static Widget appTitle(BuildContext context) {
    return GradientText(
      AppConstants.appName,
      style: Theme.of(context).textTheme.bodyLarge,
      colors: AppConstants.titleGradient,
      gradientType: GradientType.radial,
      radius: 3,
    );
  }

  static TextStyle searchTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static const Icon cameraIcon = Icon(Icons.camera_alt, color: AppTheme.primaryDark);

  static TextStyle detailTitleStyle(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryDark,
  );

  static TextStyle detailValueStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    color: AppTheme.secondaryText,
  );

  static BoxDecoration navItemDecoration(BuildContext context) => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.transparent,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}