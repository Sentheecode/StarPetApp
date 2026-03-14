import '../storage_manager.dart';

// ==================== 家园数据 ====================
class HomeData {
  static List<Map<String, dynamic>> furniture = [
    {'id': 1, 'name': '猫爬架', 'icon': '🧶', 'price': 100, 'category': '玩具'},
    {'id': 2, 'name': '狗窝', 'icon': '🛏️', 'price': 150, 'category': '床'},
    {'id': 3, 'name': '食盆', 'icon': '🥣', 'price': 50, 'category': '用品'},
    {'id': 4, 'name': '饮水机', 'icon': '💧', 'price': 80, 'category': '用品'},
    {'id': 5, 'name': '猫砂盆', 'icon': '🩰', 'price': 60, 'category': '用品'},
    {'id': 6, 'name': '玩具球', 'icon': '🎾', 'price': 30, 'category': '玩具'},
    {'id': 7, 'name': '沙发', 'icon': '🛋️', 'price': 300, 'category': '家具'},
    {'id': 8, 'name': '地毯', 'icon': '🧵', 'price': 80, 'category': '家具'},
    {'id': 9, 'name': '盆栽', 'icon': '🪴', 'price': 50, 'category': '装饰'},
    {'id': 10, 'name': '照片墙', 'icon': '🖼️', 'price': 100, 'category': '装饰'},
    {'id': 11, 'name': '小房子', 'icon': '🏠', 'price': 200, 'category': '玩具'},
    {'id': 12, 'name': '跑步机', 'icon': '🎡', 'price': 250, 'category': '玩具'},
  ];
  
  static List<Map<String, dynamic>> placedItems = [];
  static int coins = 1000;
  
  static void addItem(Map<String, dynamic> item, double x, double y) {
    placedItems.add({
      ...item,
      'x': x,
      'y': y,
      'uid': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void removeItem(int uid) {
    placedItems.removeWhere((item) => item['uid'] == uid);
  }
  
  static void moveItem(int uid, double x, double y) {
    for (var item in placedItems) {
      if (item['uid'] == uid) {
        item['x'] = x;
        item['y'] = y;
        break;
      }
    }
  }
  
  // 持久化
  static Future<void> loadItems() async {
    try {
      final data = await StorageManager.loadJsonData();
      final items = (data['homeItems'] as List<dynamic>?) ?? [];
      placedItems = items.map((item) => Map<String, dynamic>.from(item)).toList();
      print('从JSON加载家园数据: ${placedItems.length}个物品');
    } catch (e) {
      print('加载家园数据失败: $e');
    }
  }
  
  static Future<void> saveItems() async {
    if (placedItems.isEmpty) return;
    try {
      final data = await StorageManager.loadJsonData();
      data['homeItems'] = placedItems;
      await StorageManager.saveJsonData(data);
      print('家园数据已保存到JSON');
    } catch (e) {
      print('保存家园数据失败: $e');
    }
  }
}
