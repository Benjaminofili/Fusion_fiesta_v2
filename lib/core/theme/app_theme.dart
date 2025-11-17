import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
