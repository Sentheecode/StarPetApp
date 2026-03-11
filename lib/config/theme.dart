import 'package:flutter/material.dart';

class AppTheme {
  // 日式像素风配色
  static const Color primaryColor = Color(0xFF5B8C5A); // 森林绿
  static const Color secondaryColor = Color(0xFFECDDB5); // 米黄
  static const Color accentColor = Color(0xFFE8A87C); // 暖橙
  static const Color backgroundColor = Color(0xFFF5F0E6); // 浅米
  static const Color cardColor = Color(0xFFFFFBF0); // 奶白
  static const Color textPrimary = Color(0xFF3D3D3D); // 深灰
  static const Color textSecondary = Color(0xFF7D7D7D); // 中灰
  static const Color errorColor = Color(0xFFE57373); // 浅红
  static const Color successColor = Color(0xFF81C784); // 浅绿

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
