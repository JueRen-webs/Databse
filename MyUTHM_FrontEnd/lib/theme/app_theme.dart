import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // 私有构造，防止实例化
  AppTheme._();

  /// 亮色主题配置
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // 将自定义颜色库作为扩展注入
    extensions: const <ThemeExtension<dynamic>>[
      lightColors,
    ],
    // 如果想要覆盖原生组件的默认颜色，可以在这里统一设置
    scaffoldBackgroundColor: lightColors.background,
  );

  /// 暗色主题配置
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // 将自定义颜色库作为扩展注入
    extensions: const <ThemeExtension<dynamic>>[
      darkColors,
    ],
    scaffoldBackgroundColor: darkColors.background,
  );
}
