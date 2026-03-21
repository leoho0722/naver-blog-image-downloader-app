import 'package:flutter/material.dart';

/// Material 3 主題配置，提供亮色與暗色主題。
abstract final class AppTheme {
  /// 種子色彩，採用藍色系色調。
  static const Color _seedColor = Color(0xFF1565C0);

  /// 亮色主題。
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  /// 暗色主題。
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
