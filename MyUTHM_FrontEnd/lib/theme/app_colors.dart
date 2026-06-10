import 'package:flutter/material.dart';

/// Define
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

  /// creating a copy of current color without changing the original(must included)
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

  /// animation changing theme(must included)
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

/// Light theme (Strictly following Apple Design Guidelines)
const lightColors = AppColors(
  background: Color(0xFFF2F2F7),   // Apple 经典的系统级浅灰背景
  surface: Color(0xFFFFFFFF),      // 纯白卡片，突出博物馆画廊感
  primaryText: Color(0xFF1D1D1F),  // Apple 官方深色文本 (比纯黑更柔和)
  secondaryText: Color(0xFF86868B),// Apple 官方次级文本灰
  brandPrimary: Color(0xFF0422A7), // 保持 UTHM 原有主题蓝不变！
  borderColor: Color(0xFFE5E5EA),  // Apple 极细的浅灰边框色
  error: Color(0xFFFF3B30),        // Apple 官方系统红 (用于Log Out等)
  cardAlt: Color(0xFFF9F9FB),      // 稍微带一点灰的次级卡片色
);

/// Dark theme (Apple iOS Dark Mode Standard)
const darkColors = AppColors(
  background: Color(0xFF000000),   // Apple 深色模式纯黑背景
  surface: Color(0xFF1C1C1E),      // Apple 深色模式卡片底色
  primaryText: Color(0xFFF5F5F7),  // Apple 深色模式主文本
  secondaryText: Color(0xFF86868B),// Apple 深色模式次级文本
  brandPrimary: Color(0xFF4D73FF), // 保持原有稍微亮一点的蓝色不变！
  borderColor: Color(0xFF38383A),  // Apple 深色模式边框色
  error: Color(0xFFFF453A),        // Apple 深色模式红
  cardAlt: Color(0xFF2C2C2E),      // 深色模式次级卡片
);

extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}