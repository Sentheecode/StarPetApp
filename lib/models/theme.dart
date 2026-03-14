import 'package:flutter/material.dart';

// ==================== 主题配置 ====================
class AppTheme {
  // 主题配置
  static final List<Map<String, dynamic>> themes = [
    {'name': '粉紫甜心', 'primary': Color(0xFFFF69B4), 'secondary': Color(0xFF9370DB), 'background': Color(0xFFF2F2F7), 'text': Color(0xFF000000), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFFE5E5EA), 'groundBottom': Color(0xFFD1D1D6), 'skyTop': Color(0xFFF2F2F7), 'skyBottom': Color(0xFFE5E5EA)},
    {'name': '苹果简约', 'primary': Color(0xFF000000), 'secondary': Color(0xFF8E8E93), 'background': Color(0xFFF2F2F7), 'text': Color(0xFF000000), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFFE5E5EA), 'groundBottom': Color(0xFFD1D1D6), 'skyTop': Color(0xFFF2F2F7), 'skyBottom': Color(0xFFE5E5EA)},
    {'name': '清新薄荷', 'primary': Color(0xFF98FB98), 'secondary': Color(0xFF20B2AA), 'background': Color(0xFFF2F2F7), 'text': Color(0xFF000000), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFFE5E5EA), 'groundBottom': Color(0xFFD1D1D6), 'skyTop': Color(0xFFF2F2F7), 'skyBottom': Color(0xFFE5E5EA)},
    {'name': '天空蓝', 'primary': Color(0xFF87CEEB), 'secondary': Color(0xFF4169E1), 'background': Color(0xFFF2F2F7), 'text': Color(0xFF000000), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFFE5E5EA), 'groundBottom': Color(0xFFD1D1D6), 'skyTop': Color(0xFFF2F2F7), 'skyBottom': Color(0xFFE5E5EA)},
    {'name': '夕阳橙', 'primary': Color(0xFFFF6347), 'secondary': Color(0xFFFFD700), 'background': Color(0xFFF2F2F7), 'text': Color(0xFF000000), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFFE5E5EA), 'groundBottom': Color(0xFFD1D1D6), 'skyTop': Color(0xFFF2F2F7), 'skyBottom': Color(0xFFE5E5EA)},
    {'name': '暗黑模式', 'primary': Color(0xFF1C1C1E), 'secondary': Color(0xFF8E8E93), 'background': Color(0xFF000000), 'text': Color(0xFFFFFFFF), 'textSecondary': Color(0xFF8E8E93), 'groundTop': Color(0xFF1C1C1E), 'groundBottom': Color(0xFF2C2C2E), 'skyTop': Color(0xFF000000), 'skyBottom': Color(0xFF1C1C1E)},
  ];
  
  static int _themeIndex = 1;
  static int get currentThemeIndex => _themeIndex;
  static Color get primaryColor => themes[_themeIndex]['primary'];
  static Color get secondaryColor => themes[_themeIndex]['secondary'];
  static Color get backgroundColor => themes[_themeIndex]['background'];
  static Color get textColor => themes[_themeIndex]['text'];
  static Color get textSecondary => themes[_themeIndex]['textSecondary'];
  static Color get groundTop => themes[_themeIndex]['groundTop'];
  static Color get groundBottom => themes[_themeIndex]['groundBottom'];
  static Color get skyTop => themes[_themeIndex]['skyTop'];
  static Color get skyBottom => themes[_themeIndex]['skyBottom'];
  
  static void updateTheme(int index) { 
    _themeIndex = index; 
  }
  
  static void setThemeIndex(int index) {
    _themeIndex = index;
  }
}
