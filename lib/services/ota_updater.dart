import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ==================== OTA更新检测 ====================
class OTAUpdater {
  // 改成你的Tailscale IP
  static const String baseUrl = 'http://100.115.16.2:8080';
  static const int currentVersionCode = 54;
  static const String currentVersion = '2.5.0';
  
  static Map<String, dynamic>? _pendingUpdate;
  static Function(Map<String, dynamic>)? _showUpdateDialog;
  
  // 启动时检测更新
  static Future<void> checkUpdateOnStart() async {
    try {
      final updateInfo = await checkUpdate();
      if (updateInfo != null) {
        final serverVersion = updateInfo['versionCode'] ?? 1;
        if (serverVersion > currentVersionCode) {
          // 保存待显示的更新信息，在APP启动后弹出
          _pendingUpdate = updateInfo;
          // 延迟弹出，让APP先启动完成
          Future.delayed(const Duration(seconds: 2), () {
            _showUpdateDialog?.call(_pendingUpdate!);
          });
        }
      }
    } catch (e) {
      print('启动检测更新失败: $e');
    }
  }
  
  static void setUpdateDialogCallback(Function(Map<String, dynamic>) callback) {
    _showUpdateDialog = callback;
    if (_pendingUpdate != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        callback(_pendingUpdate!);
      });
    }
  }
  
  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/version.json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('检查更新失败: $e');
    }
    return null;
  }
  
  static Future<void> downloadUpdate(BuildContext context) async {
    try {
      final url = '$baseUrl/app-release.apk';
      // 实际项目中可以使用 dio 或 flutter_downloader 下载
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      print('下载更新失败: $e');
    }
  }
}
