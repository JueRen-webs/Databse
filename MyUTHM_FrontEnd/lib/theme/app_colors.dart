import 'package:flutter/material.dart';


class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color brandPrimary;
  final Color borderColor;
  final Color error;
  final Color cardAlt;

  const AppColors({
    required this.background,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.brandPrimary,
    required this.borderColor,
    required this.error,
    required this.cardAlt,
  });


  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? primaryText,
    Color? secondaryText,
    Color? brandPrimary,
    Color? borderColor,
    Color? error,
    Color? cardAlt,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      borderColor: borderColor ?? this.borderColor,
      error: error ?? this.error,
      cardAlt: cardAlt ?? this.cardAlt,
    );
  }


  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      error: Color.lerp(error, other.error, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
    );
  }
}


const lightColors = AppColors(
  background: Color(0xFFF2F2F7),
  surface: Color(0xFFFFFFFF),
  primaryText: Color(0xFF1D1D1F),
  secondaryText: Color(0xFF86868B),
  brandPrimary: Color(0xFF0422A7),
  borderColor: Color(0xFFE5E5EA),
  error: Color(0xFFFF3B30),
  cardAlt: Color(0xFFF9F9FB),
);


const darkColors = AppColors(
  background: Color(0xFF000000),
  surface: Color(0xFF1C1C1E),
  primaryText: Color(0xFFF5F5F7),
  secondaryText: Color(0xFF86868B),
  brandPrimary: Color(0xFF4D73FF),
  borderColor: Color(0xFF38383A),
  error: Color(0xFFFF453A),
  cardAlt: Color(0xFF2C2C2E),
);

extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}