import 'package:shared_preferences/shared_preferences.dart';
import '../storage_manager.dart';
import '../models/theme.dart';
import 'home_data.dart';

// ==================== 数据管理 ====================
class DataManager {
  static SharedPreferences? _prefs;
  static Map<String, dynamic> _userData = {'nickname': '点击编辑昵称', 'roles': <String>[]};
  static List<Map<String, dynamic>> _petsData = [];
  static List<Map<String, dynamic>> _postsData = [
    {'content': '今天带豆豆去公园玩，它好开心啊！🐕', 'time': '2026-03-11 15:30', 'likes': 12},
    {'content': '咪咪今天第一次尝试吃猫罐头，太可爱了！🐱', 'time': '2026-03-10 10:20', 'likes': 25},
    {'content': '新买的宠物玩具到了，俩孩子玩得不亦乐乎', 'time': '2026-03-09 18:45', 'likes': 8},
  ];
  
  static int _currentThemeIndex = 1;
  
  // 疫苗相关
  static List<Map<String, dynamic>> _vaccinesData = [];
  
  // 健康记录相关
  static List<Map<String, dynamic>> _healthRecordsData = [];
  
  static Future<void> init() async {
    // 直接加载数据，不阻塞
    _loadData();
  }
  
  // 加载数据
  static Future<void> _loadData() async {
    try {
      // 使用 JSON 文件存储
      final data = await StorageManager.loadJsonData();
      
      if (data.isNotEmpty) {
        _userData['nickname'] = data['nickname'] ?? '点击编辑昵称';
        final rolesStr = data['roles'] as String? ?? '';
        _userData['roles'] = rolesStr.isEmpty ? <String>[] : rolesStr.split(',');
        _currentThemeIndex = data['theme'] as int? ?? 1;
        AppTheme.updateTheme(_currentThemeIndex);
        _userData['coins'] = data['coins'] ?? 1000;
        _userData['lastSignIn'] = data['lastSignIn'] ?? '';
        _userData['signInDays'] = data['signInDays'] ?? 0;
        
        // 加载宠物数据
        _petsData = (data['pets'] as List<dynamic>?)?.map((p) => Map<String, dynamic>.from(p)).toList() ?? [];
        
        // 加载疫苗数据
        _vaccinesData = (data['vaccines'] as List<dynamic>?)?.map((v) => Map<String, dynamic>.from(v)).toList() ?? [];
        
        // 加载健康记录
        _healthRecordsData = (data['healthRecords'] as List<dynamic>?)?.map((h) => Map<String, dynamic>.from(h)).toList() ?? [];
        
        print('从JSON加载用户数据: ${_userData['nickname']}, ${_petsData.length}只宠物, ${_vaccinesData.length}条疫苗, ${_healthRecordsData.length}条健康记录');
      }
    } catch (e) {
      print('加载数据失败: $e');
    }
  }
  
  // 保存数据
  static Future<void> _saveData() async {
    try {
      final nickname = _userData['nickname'] ?? '点击编辑昵称';
      final roles = (_userData['roles'] as List<String>?)?.join(',') ?? '';
      final theme = _currentThemeIndex;
      final coins = _userData['coins'] ?? 1000;
      final lastSignIn = _userData['lastSignIn'] ?? '';
      final signInDays = _userData['signInDays'] ?? 0;
      
      // 保存到 JSON 文件
      final data = {
        'nickname': nickname,
        'roles': roles,
        'theme': theme,
        'coins': coins,
        'lastSignIn': lastSignIn,
        'signInDays': signInDays,
        'pets': _petsData,
        'vaccines': _vaccinesData,
        'healthRecords': _healthRecordsData,
      };
      
      await StorageManager.saveJsonData(data);
      print('用户数据已保存到JSON: $nickname, $roles, $coins');
    } catch (e) {
      print('保存用户数据失败: $e');
    }
  }
  
  // 宠物单独保存
  static Future<void> _savePets() async {
    try {
      if (_petsData.isEmpty) return;
      await _saveData();
      print('宠物数据已保存: ${_petsData.length}只');
    } catch (e) {
      print('保存宠物失败: $e');
    }
  }
  
  // ========== 用户数据 ==========
  static Map<String, dynamic> getUserData() => _userData;
  static void setUserData(String key, dynamic value) { _userData[key] = value; }
  
  static Future<void> setNickname(String name) async { 
    _userData['nickname'] = name; 
    await _saveData(); 
  }
  
  static Future<void> setRoles(List<String> roles) async { 
    _userData['roles'] = roles; 
    await _saveData(); 
  }
  
  static Future<bool> saveAndGetResult() async {
    try {
      await _saveData();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static String getNickname() => _userData['nickname'] ?? '点击编辑昵称';
  static List<String> getRoles() => List<String>.from(_userData['roles'] ?? []);
  
  // ========== 宠物数据 ==========
  static List<Map<String, dynamic>> getPets() => _petsData;
  static List<Map<String, dynamic>> getPosts() => _postsData;
  
  static Future<void> addPet(Map<String, dynamic> pet) async { 
    _petsData.add(pet); 
    await _savePets(); 
  }
  
  static Future<void> updatePet(int index, Map<String, dynamic> pet) async { 
    if (index >= 0 && index < _petsData.length) { 
      _petsData[index] = pet; 
      await _savePets(); 
    } 
  }
  
  static Future<void> deletePet(int index) async { 
    if (index >= 0 && index < _petsData.length) { 
      _petsData.removeAt(index); 
      await _savePets(); 
    } 
  }
  
  static void addPost(Map<String, dynamic> post) => _postsData.insert(0, post);
  
  // ========== 疫苗相关 ==========
  static List<Map<String, dynamic>> getVaccines() {
    // 检查是否过期或即将到期
    final now = DateTime.now();
    for (var v in _vaccinesData) {
      try {
        final date = DateTime.parse(v['date']);
        final diff = date.difference(now).inDays;
        v['isOverdue'] = diff < 0;
        v['isUpcoming'] = diff >= 0 && diff <= 30;
      } catch (e) {
        v['isOverdue'] = false;
        v['isUpcoming'] = false;
      }
    }
    return _vaccinesData;
  }
  
  static void addVaccine(Map<String, dynamic> vaccine) {
    _vaccinesData.add(vaccine);
    _saveData(); // 保存到持久化存储
    print('添加疫苗: ${vaccine['name']}');
  }
  
  // ========== 健康记录相关 ==========
  static List<Map<String, dynamic>> getHealthRecords() => _healthRecordsData;
  
  static void addHealthRecord(Map<String, dynamic> record) {
    _healthRecordsData.insert(0, record);
    _saveData(); // 保存到持久化存储
    print('添加健康记录: ${record['title']}');
  }
  
  // ========== 主题相关 ==========
  static int getCurrentTheme() => _currentThemeIndex;
  
  static Future<void> setTheme(int index) async { 
    _currentThemeIndex = index; 
    AppTheme.updateTheme(index); // 同步到UI
    await _saveData(); 
  }
  
  // ========== 金币相关 ==========
  static int getCoins() => _userData['coins'] as int? ?? 1000;
  
  static Future<void> addCoins(int amount) async { 
    _userData['coins'] = (getCoins() + amount); 
    await _setKv('coins', (_userData['coins'] ?? 1000).toString());
  }
  
  // 键值存储辅助方法
  static Future<void> _setKv(String key, String value) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(key, value);
    } catch (e) {
      
    }
  }
  
  // ========== 签到相关 ==========
  static String getLastSignIn() => _userData['lastSignIn'] as String? ?? '';
  static int getSignInDays() => _userData['signInDays'] as int? ?? 0;
  
  // ========== 统计相关 ==========
  static Map<String, dynamic> getStatistics() {
    return {
      'totalPets': _petsData.length,
      'totalPosts': _postsData.length,
      'totalVaccines': _vaccinesData.length,
      'totalHealthRecords': _healthRecordsData.length,
      'totalCoins': getCoins(),
      'signInDays': getSignInDays(),
      'lastSignIn': getLastSignIn(),
      'achievements': getAchievements().where((a) => a['unlocked'] == true).length,
      'totalAchievements': getAchievements().length,
    };
  }
  
  // 金币收支记录
  static List<Map<String, dynamic>> _coinRecords = [];
  
  static void addCoinRecord(String type, int amount, String desc) {
    _coinRecords.insert(0, {
      'type': type,
      'amount': amount,
      'desc': desc,
      'time': DateTime.now().toString().substring(0, 16),
    });
    // 只保留最近50条
    if (_coinRecords.length > 50) {
      _coinRecords = _coinRecords.sublist(0, 50);
    }
  }
  
  static List<Map<String, dynamic>> getCoinRecords() => _coinRecords;
  
  static bool canSignIn() {
    final last = getLastSignIn();
    if (last.isEmpty) return true;
    final lastDate = DateTime.tryParse(last);
    if (lastDate == null) return true;
    final now = DateTime.now();
    return now.difference(lastDate).inDays >= 1;
  }
  
  static Future<Map<String, dynamic>> signIn() async {
    if (!canSignIn()) {
      return {'success': false, 'message': '今天已签到'};
    }
    final days = getSignInDays() + 1;
    int coins = 10 + days * 5; // 基础10 + 连续天数奖励
    if (days == 7) coins += 100; // 连续7天奖励
    if (days == 30) coins += 500; // 连续30天奖励
    
    _userData['lastSignIn'] = DateTime.now().toString().substring(0, 10);
    _userData['signInDays'] = days;
    _userData['coins'] = getCoins() + coins;
    await _saveData();
    
    return {'success': true, 'days': days, 'coins': coins, 'bonus': days == 7 ? 100 : (days == 30 ? 500 : 0)};
  }
  
  // ========== 成就系统 ==========
  static List<Map<String, dynamic>> getAchievements() {
    final achievements = [
      {'id': 'first_pet', 'name': '初遇', 'desc': '添加第一只宠物', 'icon': '🐾', 'unlocked': false},
      {'id': 'two_pets', 'name': '双倍快乐', 'desc': '拥有两只宠物', 'icon': '🐾🐾', 'unlocked': false},
      {'id': 'rich', 'name': '小富翁', 'desc': '拥有1000金币', 'icon': '💰', 'unlocked': false},
      {'id': 'big_rich', 'name': '大富翁', 'desc': '拥有5000金币', 'icon': '💎', 'unlocked': false},
      {'id': 'sign_7', 'name': '坚持不懈', 'desc': '连续签到7天', 'icon': '📅', 'unlocked': false},
      {'id': 'sign_30', 'name': '签到达人', 'desc': '连续签到30天', 'icon': '🏆', 'unlocked': false},
      {'id': 'first_post', 'name': '社交达人', 'desc': '发布第一条动态', 'icon': '📱', 'unlocked': false},
      {'id': 'home_owner', 'name': '房主', 'desc': '购买第一件家具', 'icon': '🏠', 'unlocked': false},
    ];
    
    // 根据数据解锁成就
    if (_petsData.isNotEmpty) achievements[0]['unlocked'] = true;
    if (_petsData.length >= 2) achievements[1]['unlocked'] = true;
    if (getCoins() >= 1000) achievements[2]['unlocked'] = true;
    if (getCoins() >= 5000) achievements[3]['unlocked'] = true;
    if (getSignInDays() >= 7) achievements[4]['unlocked'] = true;
    if (getSignInDays() >= 30) achievements[5]['unlocked'] = true;
    if (_postsData.isNotEmpty) achievements[6]['unlocked'] = true;
    if (HomeData.placedItems.isNotEmpty) achievements[7]['unlocked'] = true;
    
    return achievements;
  }
  
  // 直接从数据库读取（用于调试）
  static Future<Map<String, dynamic>> getRawUserData() async {
    try {
      return await StorageManager.loadJsonData();
    } catch (e) {
      print('读取JSON失败: $e');
    }
    return {};
  }
}
