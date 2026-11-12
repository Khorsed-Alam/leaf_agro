import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    color: AppColors.onSurface,
  );

  static const headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  static const headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static const labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );
}

