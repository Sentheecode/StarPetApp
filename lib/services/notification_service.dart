import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==================== 通知服务 ====================
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
    _initialized = true;
  }
  
  // 显示即时通知
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'starpet_channel',
      '星宠通知',
      channelDescription: '星宠应用通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
  
  // 签到提醒
  static Future<void> showSignInReminder() async {
    await showNotification(
      title: '📅 签到提醒',
      body: '新的一天开始啦，快来签到领取金币吧！',
    );
  }
  
  // 疫苗提醒
  static Future<void> showVaccineReminder(String petName, String vaccineName) async {
    await showNotification(
      title: '💉 疫苗提醒',
      body: '$petName 的 $vaccineName 需要注意啦！',
    );
  }
  
  // 取消所有通知
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
