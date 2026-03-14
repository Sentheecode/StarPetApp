import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../models/theme.dart';

// ==================== 主题设置页面 ====================
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});
  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  int _selectedTheme = DataManager.getCurrentTheme();
  
  final List<Map<String, dynamic>> _themes = [
    {'name': '粉紫甜心', 'colors': [const Color(0xFFFF69B4), const Color(0xFF9370DB)], 'primary': const Color(0xFFFF69B4), 'secondary': const Color(0xFF9370DB)},
    {'name': '苹果简约', 'colors': [Colors.black, Colors.grey], 'primary': Colors.black, 'secondary': Colors.grey},
    {'name': '清新薄荷', 'colors': [const Color(0xFF98FB98), const Color(0xFF20B2AA)], 'primary': const Color(0xFF98FB98), 'secondary': const Color(0xFF20B2AA)},
    {'name': '天空蓝', 'colors': [const Color(0xFF87CEEB), const Color(0xFF4169E1)], 'primary': const Color(0xFF87CEEB), 'secondary': const Color(0xFF4169E1)},
    {'name': '夕阳橙', 'colors': [const Color(0xFFFF6347), const Color(0xFFFFD700)], 'primary': const Color(0xFFFF6347), 'secondary': const Color(0xFFFFD700)},
    {'name': '暗黑模式', 'colors': [Colors.black, Colors.black], 'primary': Colors.black, 'secondary': Colors.black},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('主题设置', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('选择主题风格', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...List.generate(_themes.length, (i) {
                  final theme = _themes[i];
                  final isSelected = _selectedTheme == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: theme['colors'] as List<Color>),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: isSelected ? [BoxShadow(color: (theme['colors'][0] as Color).withValues(alpha: 0.5), blurRadius: 10)] : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(theme['name'] as String, style: TextStyle(color: isSelected || i == 1 || i == 5 ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await DataManager.setTheme(_selectedTheme);
                    AppTheme.updateTheme(_selectedTheme);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已保存为 ${_themes[_selectedTheme]['name']}'), duration: const Duration(seconds: 1)),
                      );
                      Future.delayed(const Duration(milliseconds: 500), () => Navigator.pop(context));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themes[_selectedTheme]['primary'] as Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('保存主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
