import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_pkg;

enum StorageType { sqlite, json }

class StorageManager {
  static StorageType _currentType = StorageType.json;
  static late SharedPreferences _prefs;
  static String? _jsonFilePath;
  
  static StorageType get currentType => _currentType;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedType = _prefs.getString('storage_type');
    if (savedType != null) {
      _currentType = StorageType.values.firstWhere(
        (e) => e.name == savedType,
        orElse: () => StorageType.json,
      );
    }
    // Initialize JSON file path
    final dir = await getApplicationDocumentsDirectory();
    _jsonFilePath = path_pkg.join(dir.path, 'starpet_data.json');
  }
  
  static Future<void> setStorageType(StorageType type) async {
    _currentType = type;
    await _prefs.setString('storage_type', type.name);
  }
  
  static String getTypeName() {
    switch (_currentType) {
      case StorageType.sqlite:
        return 'SQLite (本地数据库)';
      case StorageType.json:
        return 'JSON (本地文件)';
    }
  }
  
  // JSON 文件操作
  static Future<Map<String, dynamic>> loadJsonData() async {
    try {
      if (_jsonFilePath == null) await init();
      final file = File(_jsonFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('加载JSON失败: $e');
    }
    return {};
  }
  
  static Future<void> saveJsonData(Map<String, dynamic> data) async {
    try {
      if (_jsonFilePath == null) await init();
      final file = File(_jsonFilePath!);
      await file.writeAsString(json.encode(data));
      print('JSON数据已保存');
    } catch (e) {
      print('保存JSON失败: $e');
    }
  }
}
