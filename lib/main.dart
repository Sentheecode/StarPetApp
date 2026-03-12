import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show Database, ConflictAlgorithm;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path_pkg;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ==================== 数据管理 ====================
class DataManager {
  static Database? _database;
  static Map<String, dynamic> _userData = {'nickname': '点击编辑昵称', 'roles': <String>[]};
  static List<Map<String, dynamic>> _petsData = [];
  static List<Map<String, dynamic>> _postsData = [
    {'content': '今天带豆豆去公园玩，它好开心啊！🐕', 'time': '2026-03-11 15:30', 'likes': 12},
    {'content': '咪咪今天第一次尝试吃猫罐头，太可爱了！🐱', 'time': '2026-03-10 10:20', 'likes': 25},
    {'content': '新买的宠物玩具到了，俩孩子玩得不亦乐乎', 'time': '2026-03-09 18:45', 'likes': 8},
  ];
  
  static Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  static Future<sqflite.Database> _initDB() async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = path_pkg.join(dbPath, 'starpet.db');
    
    return await sqflite.openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY,
            nickname TEXT,
            roles TEXT,
            theme INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE pets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            gender TEXT,
            color TEXT,
            breed TEXT,
            feature TEXT
          )
        ''');
        // 初始化用户数据
        await db.insert('user', {'id': 1, 'nickname': '点击编辑昵称', 'roles': '', 'theme': 1});
        // 简单键值表（用于存储额外数据）
        await db.execute('''
          CREATE TABLE kv_store(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
        // 家园表
        await db.execute('''
          CREATE TABLE home_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId INTEGER,
            name TEXT,
            icon TEXT,
            price INTEGER,
            category TEXT,
            x REAL,
            y REAL,
            uid INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // 创建键值表
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS kv_store(
                key TEXT PRIMARY KEY,
                value TEXT
              )
            ''');
          } catch(e) {}
        }
      },
    );
  }
  
  static Future<void> init() async {
    await database;
    await _loadData();
    await HomeData.loadItems();
  }
  
  // 加载数据
  static Future<void> _loadData() async {
    try {
      final db = await database;
      // 从 kv_store 加载所有用户数据
      _userData['nickname'] = await _getKv('nickname', '点击编辑昵称');
      final rolesStr = await _getKv('roles', '');
      _userData['roles'] = rolesStr.isEmpty ? <String>[] : rolesStr.split(',');
      _currentThemeIndex = int.tryParse(await _getKv('theme', '1')) ?? 1;
      _userData['theme'] = _currentThemeIndex;
      _userData['coins'] = int.tryParse(await _getKv('coins', '1000')) ?? 1000;
      _userData['lastSignIn'] = await _getKv('lastSignIn', '');
      _userData['signInDays'] = int.tryParse(await _getKv('signInDays', '0')) ?? 0;
      
      print('=== 从KV加载: nickname=${_userData['nickname']}, theme=$_currentThemeIndex, coins=${_userData['coins']}, signInDays=${_userData['signInDays']} ===');
      
      // 加载宠物数据
      final petsList = await db.query('pets');
      _petsData = petsList.map((p) => Map<String, dynamic>.from(p)).toList();
    } catch (e) {
      print('加载数据失败: $e');
    }
  }
  
  // 保存数据
  static Future<void> _saveData() async {
    try {
      final db = await database;
      
      // 保存到 user 表（只保存基本信息）
      await db.delete('user', where: 'id = ?', whereArgs: [1]);
      await db.insert('user', {'id': 1, 'nickname': _userData['nickname'] ?? '点击编辑昵称', 'roles': (_userData['roles'] as List<String>).join(','), 'theme': _currentThemeIndex});
      // 所有用户数据都存到 kv_store
      await _setKv('nickname', _userData['nickname'] ?? '点击编辑昵称');
      await _setKv('roles', (_userData['roles'] as List<String>).join(','));
      await _setKv('theme', _currentThemeIndex.toString());
      await _setKv('coins', (_userData['coins'] ?? 1000).toString());
      await _setKv('lastSignIn', _userData['lastSignIn'] ?? '');
      await _setKv('signInDays', (_userData['signInDays'] ?? 0).toString());
      print('=== 保存到KV: nickname=${_userData['nickname']}, theme=$_currentThemeIndex, coins=${_userData['coins']}, signInDays=${_userData['signInDays']} ===');
    } catch (e) {
      print('保存数据失败: $e');
    }
  }
  
  // 宠物单独保存
  static Future<void> _savePets() async {
    try {
      final db = await database;
      // 清空宠物表，重新插入
      await db.delete('pets');
      for (var pet in _petsData) {
        await db.insert('pets', {
          'name': pet['name'],
          'type': pet['type'],
          'gender': pet['gender'],
          'color': pet['color'],
          'breed': pet['breed'],
          'feature': pet['feature'],
        });
      }
    } catch (e) {
      print('保存宠物失败: $e');
    }
  }
  
  static Map<String, dynamic> getUserData() => _userData;
  static Future<void> setNickname(String name) async { _userData['nickname'] = name; await _saveData(); }
  static Future<void> setRoles(List<String> roles) async { _userData['roles'] = roles; await _saveData(); }
  static String getNickname() => _userData['nickname'] ?? '点击编辑昵称';
  static List<String> getRoles() => List<String>.from(_userData['roles'] ?? []);
  static List<Map<String, dynamic>> getPets() => _petsData;
  static List<Map<String, dynamic>> getPosts() => _postsData;
  static Future<void> addPet(Map<String, dynamic> pet) async { _petsData.add(pet); await _savePets(); }
  static Future<void> updatePet(int index, Map<String, dynamic> pet) async { if (index >= 0 && index < _petsData.length) { _petsData[index] = pet; await _savePets(); } }
  static Future<void> deletePet(int index) async { if (index >= 0 && index < _petsData.length) { _petsData.removeAt(index); await _savePets(); } }
  static void addPost(Map<String, dynamic> post) => _postsData.insert(0, post);
  
  // 主题相关
  static int _currentThemeIndex = 1;
  static int getCurrentTheme() => _currentThemeIndex;
  static Future<void> setTheme(int index) async { _currentThemeIndex = index; await _saveData(); }
  
  // 键值存储辅助方法
  static Future<void> _setKv(String key, String value) async {
    try {
      final db = await database;
      await db.insert('kv_store', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('保存kv失败: $key=$value, error=$e');
    }
  }
  
  static Future<String> _getKv(String key, String defaultValue) async {
    try {
      final db = await database;
      final result = await db.query('kv_store', where: 'key = ?', whereArgs: [key]);
      if (result.isNotEmpty) {
        return result.first['value']?.toString() ?? defaultValue;
      }
    } catch (e) {
      print('读取kv失败: $key, error=$e');
    }
    return defaultValue;
  }
  
  // 金币相关
  static int getCoins() => _userData['coins'] as int? ?? 1000;
  static Future<void> addCoins(int amount) async { 
    _userData['coins'] = (getCoins() + amount); 
    await _setKv('coins', (_userData['coins'] ?? 1000).toString());
  }
  
  // 签到相关
  static String getLastSignIn() => _userData['lastSignIn'] as String? ?? '';
  static int getSignInDays() => _userData['signInDays'] as int? ?? 0;
  
  // 直接从数据库读取（用于调试）
  static Future<Map<String, dynamic>> getRawUserData() async {
    try {
      final db = await database;
      // 获取 user 表
      final userResult = await db.query('user', where: 'id = ?', whereArgs: [1]);
      // 获取 kv_store
      final kvResult = await db.query('kv_store');
      final Map<String, dynamic> data = {};
      if (userResult.isNotEmpty) {
        data.addAll(userResult.first);
      }
      for (var row in kvResult) {
        data[row['key'].toString()] = row['value'];
      }
      return data;
    } catch (e) {
      print('读取原始用户数据失败: $e');
    }
    return {};
  }
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
  
  // 成就系统
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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.init();
  // 启动时检测更新
  OTAUpdater.checkUpdateOnStart();
  runApp(const StarPetApp());
}

class StarPetApp extends StatefulWidget {
  const StarPetApp({super.key});

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
  static void updateTheme(int index) { _themeIndex = index; }

  @override
  State<StarPetApp> createState() => StarPetAppState();
}

class StarPetAppState extends State<StarPetApp> {
  static StarPetAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<StarPetAppState>();
  }

  @override
  void initState() {
    super.initState();
    // 从数据库加载主题
    final savedTheme = DataManager.getCurrentTheme();
    print('=== StarPetAppState init: savedTheme=$savedTheme ===');
    StarPetApp._themeIndex = savedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarPet - 星宠',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: StarPetApp.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: StarPetApp.primaryColor,
          primary: StarPetApp.primaryColor,
          secondary: StarPetApp.secondaryColor,
        ),
        scaffoldBackgroundColor: StarPetApp.backgroundColor,
        fontFamily: 'System',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _petFrameIndex = 1;
  Timer? _frameTimer;
  
  final List<Map<String, dynamic>> pets = [
    {'name': '咪咪', 'breed': '英短', 'type': 'cat', 'gender': 'female', 'color': '蓝色', 'feature': '粘人'},
    {'name': '豆豆', 'breed': '柯基', 'type': 'dog', 'gender': 'male', 'color': '金色', 'feature': '忠诚'},
  ];

  @override
  void initState() {
    super.initState();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _petFrameIndex = (_petFrameIndex % 4) + 1;
      });
    });
    
    // 设置OTA更新弹窗回调
    OTAUpdater.setUpdateDialogCallback((updateInfo) {
      _showUpdateDialog(updateInfo);
    });
  }
  
  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('发现新版本!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${updateInfo['version'] ?? '新版本'}'),
            const SizedBox(height: 8),
            Text('更新说明: ${updateInfo['releaseNote'] ?? '暂无'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('稍后再说'),
          ),
          TextButton(
            onPressed: () {
              OTAUpdater.downloadUpdate(context);
              Navigator.pop(context);
            },
            child: Text('立即更新'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildServiceTab(),
          _buildSocialTab(),
          _buildDeviceTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==================== 家园Tab ====================
  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [StarPetApp.skyTop, StarPetApp.skyBottom],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            _buildHeader(),
            // 宠物信息栏
            _buildPetInfoBar(),
            // 家园场景
            Expanded(child: _buildHomeScene()),
            // 底部状态栏
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：Logo + 标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: StarPetApp.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pets,
                  color: StarPetApp.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '星宠',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: StarPetApp.textColor,
                ),
              ),
            ],
          ),
          // 右侧：等级 + 设置
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Lv.1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings,
                  color: StarPetApp.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: StarPetApp.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 主宠物头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: StarPetApp.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                pets[0]['type'] == 'cat' ? '🐱' : '🐕',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 宠物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pets[0]['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: StarPetApp.textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pets[0]['gender'] == 'female' ? '♀ 雌性' : '♂ 雄性',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pets[0]['type'] == 'cat' ? '🐱' : '🐕'} ${pets[0]['breed']} · 1岁',
                  style: TextStyle(
                    fontSize: 13,
                    color: StarPetApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 更多宠物
          if (pets.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: StarPetApp.backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    '+${pets.length - 1}',
                    style: TextStyle(
                      color: StarPetApp.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.pets, size: 16, color: StarPetApp.primaryColor),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeScene() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: StarPetApp.primaryColor.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 天空背景
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [StarPetApp.skyTop, StarPetApp.skyBottom],
                ),
              ),
            ),
            // 云朵装饰
            const Positioned(
              top: 30,
              left: 40,
              child: Text('☁️', style: TextStyle(fontSize: 40)),
            ),
            const Positioned(
              top: 60,
              right: 60,
              child: Text('☁️', style: TextStyle(fontSize: 30)),
            ),
            // 地面
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [StarPetApp.groundTop, StarPetApp.groundBottom],
                  ),
                ),
              ),
            ),
            // 地面纹理（草地）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: StarPetApp.groundTop.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    20,
                    (index) => Text('🌿', style: TextStyle(fontSize: 12 + (index % 3) * 2)),
                  ),
                ),
              ),
            ),
            // 猫咪图片1
            Positioned(
              bottom: 60,
              left: 30,
              child: Image.asset(
                'assets/pets/cat/british_short/british_short_01.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            // 精灵图动画
            Positioned(
              bottom: 60,
              left: 30,
              child: Image.asset(
                'assets/pets/cat/british_short/british_short_01_frame$_petFrameIndex.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text('🐱', style: TextStyle(fontSize: 72)),
              ),
            ),
            // 第二只猫
            Positioned(
              bottom: 40,
              right: 40,
              child: Image.asset(
                'assets/pets/cat/british_short/british_short_02_frame1.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text('🐱', style: TextStyle(fontSize: 56)),
              ),
            ),
            // 猫咪图片3
            Positioned(
              bottom: 80,
              right: 80,
              child: Image.asset(
                'assets/pets/cat/british_short/british_short_03.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text('🐱', style: TextStyle(fontSize: 40)),
              ),
            ),
            // 家具 - 猫爬架
            const Positioned(
              bottom: 30,
              right: 150,
              child: Text('🪜', style: TextStyle(fontSize: 56)),
            ),
            // 家具 - 床
            const Positioned(
              bottom: 25,
              left: 120,
              child: Text('🛏️', style: TextStyle(fontSize: 40)),
            ),
            // 已选家具标签
            Positioned(
              top: 20,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFurnitureChip('木质地板', Icons.grass),
                  _buildFurnitureChip('猫爬架', Icons.layers),
                  _buildFurnitureChip('简约床', Icons.bed),
                ],
              ),
            ),
            // 添加家具按钮
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureChip(String name, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: StarPetApp.primaryColor),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: StarPetApp.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 18, color: Colors.black),
          SizedBox(width: 10),
          Text(
            '🏡 家园场景 - 装修中',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 服务Tab ====================
  Widget _buildServiceTab() {
    return Container(
      color: StarPetApp.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    '同城服务',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StarPetApp.textColor,
                    ),
                  ),
                ],
              ),
            ),
            // 功能卡片
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    '🦷', 
                    '宠物美容', 
                    '洗澡、剪毛、护理',
                    StarPetApp.primaryColor,
                  ),
                  _buildServiceCard(
                    '🏥', 
                    '宠物医疗', 
                    '疫苗、体检、就诊',
                    const Color(0xFF4CAF50),
                  ),
                  _buildServiceCard(
                    '🦴', 
                    '宠物寄养', 
                    '短期长期寄养',
                    const Color(0xFFFF9800),
                  ),
                  _buildServiceCard(
                    '🎓', 
                    '宠物培训', 
                    '行为训练、技能班',
                    const Color(0xFF2196F3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String emoji, String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: StarPetApp.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: StarPetApp.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 社交Tab ====================
  Widget _buildSocialTab() {
    final posts = DataManager.getPosts();
    return Container(
      color: StarPetApp.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '宠物社交',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StarPetApp.textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostPage()));
                      if (result == true) setState(() {});
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.add, color: Colors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            // 朋友圈内容
            Expanded(
              child: posts.isEmpty
                ? const Center(child: Text('还没有博文\n点击右上角发布', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPostCard(
                    '🐱 咪咪',
                    '今天学会了握手技能！🎉',
                    '👍 12  💬 3',
                    '刚刚',
                  ),
                  _buildPostCard(
                    '🐕 豆豆',
                    '遛弯遇到好多小伙伴',
                    '👍 24  💬 8',
                    '2小时前',
                  ),
                  _buildPostCard(
                    '🐰 小白',
                    '新买的玩具超喜欢',
                    '👍 8  💬 2',
                    '昨天',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(String author, String content, String stats, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(author.split(' ')[0], style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.split(' ')[1],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: StarPetApp.textColor,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: StarPetApp.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: StarPetApp.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                stats,
                style: TextStyle(
                  fontSize: 13,
                  color: StarPetApp.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 设备Tab ====================
  Widget _buildDeviceTab() {
    return Container(
      color: StarPetApp.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    '设备互联',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StarPetApp.textColor,
                    ),
                  ),
                ],
              ),
            ),
            // 设备列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDeviceCard(
                    '📷', 
                    '智能摄像头', 
                    '未连接',
                    false,
                  ),
                  _buildDeviceCard(
                    '📱', 
                    '宠物定位器', 
                    '未连接',
                    false,
                  ),
                  _buildDeviceCard(
                    '⚖️', 
                    '智能体重秤', 
                    '未连接',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String emoji, String title, String status, bool isConnected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: StarPetApp.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: StarPetApp.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: isConnected ? Colors.green : StarPetApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected 
                ? Colors.green.withValues(alpha: 0.1)
                : StarPetApp.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isConnected ? '已连接' : '添加',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isConnected ? Colors.green : StarPetApp.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 个人中心Tab ====================
  Widget _buildProfileTab() {
    final nickname = DataManager.getNickname();
    final roles = DataManager.getRoles();
    return Container(
      color: StarPetApp.backgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 头像和用户信息
            GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: StarPetApp.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text('👤', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nickname,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: 123456',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.white70, size: 20),
                      ],
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: roles.map((r) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text(r, style: TextStyle(color: Colors.white, fontSize: 12)),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 菜单项
            _buildMenuItem(Icons.pets, '我的宠物', '添加/管理宠物', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PetListPage()));
            }),
            _buildMenuItem(Icons.home, '我的家园', '查看/编辑家园', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeEditPage()));
            }),
            _buildMenuItem(Icons.calendar_today, '每日签到', '领取金币奖励', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
            }),
            _buildMenuItem(Icons.emoji_events, '成就徽章', '查看成就进度', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsPage()));
            }),
            _buildMenuItem(Icons.settings, '主题设置', '切换主题风格', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeSettingsPage()));
            }),
            _buildMenuItem(Icons.notifications, '消息通知', '推送消息设置', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }),
            _buildMenuItem(Icons.help, '帮助与反馈', '常见问题', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFeedbackPage()));
            }),
            _buildMenuItem(Icons.bug_report, '调试信息', '查看数据状态', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DebugPage()));
            }),
            _buildMenuItem(Icons.info, '关于我们', '版本信息', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: StarPetApp.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: StarPetApp.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: StarPetApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: StarPetApp.textSecondary,
          ),
        ],
      ),
    ),
    );
  }

  // 添加宠物流程
  void _showAddPetFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PetListPage()),
    );
  }

  // ==================== 底部导航栏 ====================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, '家园'),
              _buildNavItem(1, Icons.local_shipping_rounded, '服务'),
              _buildNavItem(2, Icons.pets_rounded, '社交'),
              _buildNavItem(3, Icons.devices_rounded, '设备'),
              _buildNavItem(4, Icons.person_rounded, '我的'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? StarPetApp.primaryColor : StarPetApp.textSecondary;
    
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? StarPetApp.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 角色选择页面
class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  final List<Map<String, dynamic>> roles = [
    {'id': 1, 'name': '宠物主人', 'icon': '🐾', 'desc': '养宠物，装饰家园'},
    {'id': 2, 'name': '上门喂养/寄养', 'icon': '🏠', 'desc': '提供上门服务和寄养'},
    {'id': 3, 'name': '云养宠', 'icon': '☁️', 'desc': '远程吸宠，交友互动'},
  ];
  
  final Set<int> selectedRoles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('选择角色', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('请选择您的角色\n（可多选）', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  final isSelected = selectedRoles.contains(role['id']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) selectedRoles.remove(role['id']);
                        else selectedRoles.add(role['id']);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(width: 60, height: 60, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: Center(child: Text(role['icon'], style: TextStyle(fontSize: 30)))),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(role['desc'], style: TextStyle(fontSize: 13, color: Colors.grey[600]))])),
                          if (isSelected) Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: Icon(Icons.check, color: Colors.white, size: 18)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRoles.isEmpty ? null : () { Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('下一步', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 宠物列表页面 ====================
class PetListPage extends StatefulWidget {
  const PetListPage({super.key});
  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  void _showPetOptions(BuildContext context, int index, Map<String, dynamic> pet) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pet['name'] ?? '宠物', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('查看详情'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailPage(petIndex: index)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetPage(petIndex: index)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await DataManager.deletePet(index);
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final pets = DataManager.getPets();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('我的宠物', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;
            return GestureDetector(
              onTap: () => _showPetOptions(context, index, pet),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Center(child: Text((pet['type'] ?? 'cat') == 'cat' ? '🐱' : '🐕', style: TextStyle(fontSize: 36)))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet['name'] ?? '宠物', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${pet['breed'] ?? ''} · ${pet['color'] ?? ''}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          const SizedBox(height: 2),
                          Text('${(pet['gender'] ?? 'female') == 'female' ? '雌性' : '雄性'} · ${pet['feature'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPetPage()));
              setState(() {});
            },
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!, width: 1)),
              child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.grey, size: 32), SizedBox(height: 4), Text('添加宠物', style: TextStyle(color: Colors.grey, fontSize: 14))])),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 添加宠物页面 ====================
class AddPetPage extends StatefulWidget {
  final int? petIndex;
  const AddPetPage({super.key, this.petIndex});
  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  String? petType;
  String? gender;
  String? breed;
  String? color;
  String? feature;
  final _nameController = TextEditingController();
  bool _showPetAnimation = false;

  final Map<String, List<String>> breeds = {'cat': ['英短', '美短', '暹罗', '布偶', '波斯', '孟加拉', '缅因', '其他'], 'dog': ['柯基', '柴犬', '哈士奇', '金毛', '拉布拉多', '边牧', '德牧', '泰迪', '萨摩耶', '博美', '其他']};
  final Map<String, List<String>> colors = {'cat': ['蓝色', '金色', '银色', '橘色', '黑色', '白色', '三花', '玳瑁', '铁包银'], 'dog': ['金色', '黑色', '白色', '灰色', '黄色', '陨石', '铁包金', '铁包银', '三色']};
  final Map<String, List<String>> features = {'cat': ['粘人', '高冷', '活泼', '安静', '贪吃', '好奇'], 'dog': ['忠诚', '活泼', '粘人', '护主', '贪玩', '安静']};

  @override
  void initState() {
    super.initState();
    if (widget.petIndex != null) {
      final pet = DataManager.getPets()[widget.petIndex!];
      _nameController.text = pet['name'] ?? '';
      petType = pet['type'] as String?;
      gender = pet['gender'] as String?;
      breed = pet['breed'] as String?;
      color = pet['color'] as String?;
      feature = pet['feature'] as String?;
    }
  }

  Widget _buildCard(String emoji, String label, bool sel, VoidCallback tap) => GestureDetector(onTap: tap, child: Container(width: 150, height: 100, decoration: BoxDecoration(color: sel ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? Colors.black : Colors.grey[300]!)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: TextStyle(fontSize: 36)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 14, color: sel ? Colors.white : Colors.black))])));

  Future<void> _savePet() async {
    final name = _nameController.text.isEmpty ? '宠物${DataManager.getPets().length + 1}' : _nameController.text;
    final pet = {'name': name, 'type': petType ?? 'cat', 'gender': gender ?? 'female', 'color': color ?? '', 'breed': breed ?? '', 'feature': feature ?? ''};
    if (widget.petIndex != null) await DataManager.updatePet(widget.petIndex!, pet);
    else await DataManager.addPet(pet);
    setState(() => _showPetAnimation = true);
  }

  Widget _buildAnim() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () { setState(() => _showPetAnimation = false); Navigator.pop(context); },
        child: Container(
          color: Colors.black.withValues(alpha: 0.9),
          child: Stack(
            children: [
              // 背景闪光效果
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          Color.lerp(const Color(0xFFFFD700), const Color(0xFFFF6B6B), value)!.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // 中心内容
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // RARE / EPIC 标签
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B6B)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: Text('★★★ 新宠物 ★★★', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // 宠物图标放大弹跳
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 160, height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(colors: [Color(0xFFFFE4B5), Color(0xFFFFD700)]),
                              boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.8), blurRadius: 40, spreadRadius: 10)],
                            ),
                            child: Center(child: Text(petType == 'cat' ? '🐱' : '🐕', style: TextStyle(fontSize: 80))),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // 宠物名字
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              Text(
                                _nameController.text.isEmpty ? '新宠物' : _nameController.text,
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 10)]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text('${petType == 'cat' ? '猫咪' : '狗狗'} · ${gender == 'female' ? '雌性' : '雄性'}', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // 炫光文字
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text('✨ 恭喜获得新伙伴! ✨', style: TextStyle(fontSize: 20, color: Color(0xFFFFD700), fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                    Text('点击任意处关闭', style: TextStyle(color: Colors.white38, fontSize: 14)),
                  ],
                ),
              ),
              // 飘落的星星粒子
              ...List.generate(20, (i) => _buildParticle(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = index * 17 % 100;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500 + random * 50),
      builder: (context, value, child) {
        return Positioned(
          left: (random / 100) * 400 + 50,
          top: -30 + (value * 900),
          child: Opacity(
            opacity: (1 - value) * 0.8,
            child: Transform.rotate(
              angle: value * 6.28,
              child: Text(['✨', '⭐', '🌟', '💫', '✦'][index % 5], style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: Text(widget.petIndex != null ? '编辑宠物' : '添加宠物', style: TextStyle(color: Colors.black)), centerTitle: true),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (widget.petIndex == null) ...[_buildSectionTitle('1. 选择宠物类型'), const SizedBox(height: 12), Row(children: [_buildCard('🐱', '猫咪', petType == 'cat', () => setState(() => petType = 'cat')), const SizedBox(width: 12), _buildCard('🐕', '狗狗', petType == 'dog', () => setState(() => petType = 'dog'))]), const SizedBox(height: 24)],
                _buildSectionTitle(widget.petIndex != null ? '1. 宠物名字' : '2. 宠物名字'),
                const SizedBox(height: 12),
                TextField(controller: _nameController, decoration: InputDecoration(hintText: '请输入宠物名字', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 24),
                _buildSectionTitle(widget.petIndex != null ? '2. 选择性别' : '3. 选择性别'),
                const SizedBox(height: 12),
                Row(children: [_buildCard('♀', '雌性', gender == 'female', () => setState(() => gender = 'female')), const SizedBox(width: 12), _buildCard('♂', '雄性', gender == 'male', () => setState(() => gender = 'male'))]),
                const SizedBox(height: 24),
                if (gender != null) ...[_buildSectionTitle(widget.petIndex != null ? '3. 选择花色' : '4. 选择花色'), const SizedBox(height: 12), _buildGrid(colors[petType] ?? [], color, (c) => setState(() => color = c)), const SizedBox(height: 24)],
                if (color != null && petType != null) ...[_buildSectionTitle(widget.petIndex != null ? '4. 选择品种' : '5. 选择品种'), const SizedBox(height: 12), _buildGrid(breeds[petType] ?? [], breed, (b) => setState(() => breed = b)), const SizedBox(height: 24)],
                if (breed != null && petType != null) ...[_buildSectionTitle(widget.petIndex != null ? '5. 选择特征' : '6. 选择特征'), const SizedBox(height: 12), _buildGrid(features[petType] ?? [], feature, (f) => setState(() => feature = f)), const SizedBox(height: 24)],
                if (feature != null) SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _savePet, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(widget.petIndex != null ? '保存修改' : '保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
          if (_showPetAnimation) _buildAnim(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t) => Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Widget _buildGrid(List<String> items, String? sel, Function(String) onTap) => Wrap(spacing: 8, runSpacing: 8, children: items.map((i) => GestureDetector(onTap: () => onTap(i), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: sel == i ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(i, style: TextStyle(color: sel == i ? Colors.white : Colors.black))))).toList());
}

// ==================== 宠物详情页面 ====================
class PetDetailPage extends StatelessWidget {
  final int petIndex;
  const PetDetailPage({super.key, required this.petIndex});

  @override
  Widget build(BuildContext context) {
    final pets = DataManager.getPets();
    if (petIndex >= pets.length) {
      return Scaffold(appBar: AppBar(title: Text('宠物详情')), body: const Center(child: Text('宠物不存在')));
    }
    final pet = pets[petIndex];
    final isCat = pet['type'] == 'cat';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(pet['name'] ?? '宠物详情', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetPage(petIndex: petIndex))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 宠物头像
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isCat ? [const Color(0xFFFF69B4), const Color(0xFF9370DB)] : [const Color(0xFF87CEEB), const Color(0xFF4169E1)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Center(child: Text(isCat ? '🐱' : '🐕', style: TextStyle(fontSize: 60))),
            ),
            const SizedBox(height: 16),
            Text(pet['name'] ?? '未命名', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(pet['gender'] == 'male' ? '🚹 男孩子' : '🚺 女孩子', isCat ? Colors.pink : Colors.blue),
                const SizedBox(width: 8),
                _buildTag(pet['breed'] ?? '未知品种', Colors.grey),
              ],
            ),
            const SizedBox(height: 30),
            
            // 详细信息卡片
            _buildInfoCard([
              {'icon': Icons.pets, 'label': '类型', 'value': isCat ? '猫咪' : '狗狗'},
              {'icon': Icons.palette, 'label': '毛色', 'value': pet['color'] ?? '未知'},
              {'icon': Icons.star, 'label': '特点', 'value': (pet['features'] as List?)?.join('、') ?? '暂无'},
              {'icon': Icons.calendar_today, 'label': '添加时间', 'value': pet['createdAt']?.toString().substring(0, 10) ?? '未知'},
            ]),
            
            const SizedBox(height: 20),
            
            // 成长记录（模拟数据）
            _buildGrowthCard(),
            
            const SizedBox(height: 20),
            
            // 趣事记录
            _buildMemoryCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
  );
  
  Widget _buildInfoCard(List<Map<String, dynamic>> items) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
    child: Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)), child: Icon(item['icon'], size: 20, color: Colors.grey[600])),
          const SizedBox(width: 12),
          Text(item['label'], style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(item['value'], style: TextStyle(fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
    ),
  );
  
  Widget _buildGrowthCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [Icon(Icons.trending_up, color: Colors.green), SizedBox(width: 8), Text('成长记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        _buildGrowthItem('体重', '3.5kg', '正常', Colors.green),
        _buildGrowthItem('身高', '25cm', '正常', Colors.green),
        _buildGrowthItem('心情', '开心 😄', '良好', Colors.orange),
      ],
    ),
  );
  
  Widget _buildGrowthItem(String label, String value, String status, Color statusColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Text(label, style: TextStyle(color: Colors.grey[600])),
      const Spacer(),
      Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(width: 12),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 12))),
    ]),
  );
  
  Widget _buildMemoryCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [Icon(Icons.auto_stories, color: Colors.purple), SizedBox(width: 8), Text('美好回忆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        _buildMemoryItem('2026-03-10', '今天第一次见到主人，好开心！'),
        _buildMemoryItem('2026-03-08', '学会了新技能-坐下'),
      ],
    ),
  );
  
  Widget _buildMemoryItem(String date, String content) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)), child: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey))),
      const SizedBox(width: 12),
      Expanded(child: Text(content)),
    ]),
  );
}

// ==================== 发帖页面 ====================
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  
  void _publishPost() {
    if (_contentController.text.isEmpty) return;
    DataManager.addPost({'content': _contentController.text, 'time': DateTime.now().toString().substring(0, 16), 'likes': 0});
    Navigator.pop(context, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)), title: Text('发布博文', style: TextStyle(color: Colors.black)), centerTitle: true, actions: [TextButton(onPressed: _publishPost, child: Text('发布', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)))]),
      body: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _contentController, maxLines: null, minLines: 10, decoration: const InputDecoration(hintText: '分享你和宠物的故事...', border: InputBorder.none), style: TextStyle(fontSize: 16))),
    );
  }
}

// ==================== 编辑资料页面 ====================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nicknameController;
  Set<int> selectedRoles = {};
  
  final List<Map<String, String>> roles = [
    {'id': '1', 'name': '宠物主人', 'icon': '🐾', 'desc': '养宠物的主人'},
    {'id': '2', 'name': '上门喂养', 'icon': '🏠', 'desc': '提供上门服务'},
    {'id': '3', 'name': '云养宠', 'icon': '☁️', 'desc': '远程吸宠'},
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: DataManager.getNickname());
    final currentRoles = DataManager.getRoles();
    for (var role in roles) {
      if (currentRoles.contains(role['name'])) {
        selectedRoles.add(int.parse(role['id']!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('编辑资料', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              await DataManager.setNickname(_nicknameController.text.isEmpty ? '点击编辑昵称' : _nicknameController.text);
              final selectedNames = roles.where((r) => selectedRoles.contains(int.parse(r['id']!))).map((r) => r['name']!).toList();
              await DataManager.setRoles(selectedNames);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('保存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('昵称', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              hintText: '请输入昵称',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Text('选择角色（可多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...roles.map((role) {
            final id = int.parse(role['id']!);
            final isSelected = selectedRoles.contains(id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) selectedRoles.remove(id);
                  else selectedRoles.add(id);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(role['icon']!, style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role['name']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                          Text(role['desc']!, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white70 : Colors.grey[600])),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ==================== OTA更新检测 ====================
class OTAUpdater {
  // 改成你的Tailscale IP
  static const String baseUrl = 'http://100.64.77.197:8080';
  static const int currentVersionCode = 25;
  static const String currentVersion = '1.5.0';
  
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
  
  static Map<String, dynamic>? _pendingUpdate;
  static Function(Map<String, dynamic>)? _showUpdateDialog;
  
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
      final db = await DataManager.database;
      final items = await db.query('home_items');
      placedItems = items.map((item) => {
        'id': item['itemId'],
        'name': item['name'],
        'icon': item['icon'],
        'price': item['price'],
        'category': item['category'],
        'x': item['x'],
        'y': item['y'],
        'uid': item['uid'],
      }).toList();
      print('=== 加载家园物品: ${placedItems.length} 个 ===');
    } catch (e) {
      print('加载家园数据失败: $e');
    }
  }
  
  static Future<void> saveItems() async {
    try {
      final db = await DataManager.database;
      await db.delete('home_items');
      for (var item in placedItems) {
        await db.insert('home_items', {
          'itemId': item['id'],
          'name': item['name'],
          'icon': item['icon'],
          'price': item['price'],
          'category': item['category'],
          'x': item['x'],
          'y': item['y'],
          'uid': item['uid'],
        });
      }
    } catch (e) {
      print('保存家园数据失败: $e');
    }
  }
}

// ==================== 我的家园页面 ====================
class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});
  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  int _selectedTab = 0; // 0: 家园 1: 商店
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('我的家园', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('${DataManager.getCoins()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab 切换
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildTab(0, '🏡 我的家园')),
                Expanded(child: _buildTab(1, '🛒 家具商店')),
              ],
            ),
          ),
          // 内容
          Expanded(
            child: _selectedTab == 0 ? _buildHomeView() : _buildShopView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? StarPetApp.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.w500)),
      ),
    );
  }
  
  // 家园视图
  Widget _buildHomeView() {
    return Stack(
      children: [
        // 草地背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green[300]!, Colors.green[400]!],
            ),
          ),
        ),
        // 放置的家具
        ...HomeData.placedItems.map((item) => Positioned(
          left: item['x'],
          top: item['y'],
          child: GestureDetector(
            onLongPress: () => _showItemOptions(item['uid']),
            child: Draggable<Map<String, dynamic>>(
              data: item,
              feedback: Text(item['icon'], style: const TextStyle(fontSize: 40)),
              childWhenDragging: const SizedBox(),
              onDragEnd: (details) {
                final box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.offset);
                HomeData.moveItem(item['uid'], local.dx - 25, local.dy - 25);
                HomeData.saveItems();
                setState(() {});
              },
              child: Text(item['icon'], style: const TextStyle(fontSize: 50)),
            ),
          ),
        )),
        // 空状态
        if (HomeData.placedItems.isEmpty)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🛒', style: TextStyle(fontSize: 60)),
                SizedBox(height: 16),
                Text('去商店买些家具吧~', style: TextStyle(fontSize: 18, color: Colors.white70)),
              ],
            ),
          ),
        // 提示
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
              child: const Text('长按删除 / 拖拽移动', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }
  
  // 商店视图
  Widget _buildShopView() {
    final categories = ['全部', '玩具', '床', '用品', '家具', '装饰'];
    return Column(
      children: [
        // 分类
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: categories.map((cat) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(cat, style: const TextStyle(fontSize: 14)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // 商品列表
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: HomeData.furniture.length,
            itemBuilder: (context, index) {
              final item = HomeData.furniture[index];
              final canAfford = DataManager.getCoins() >= item['price'];
              return GestureDetector(
                onTap: canAfford ? () => _buyItem(item) : null,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['icon'], style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('🪙${item['price']}', style: TextStyle(fontSize: 11, color: canAfford ? Colors.amber[700] : Colors.red)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _buyItem(Map<String, dynamic> item) {
    if (DataManager.getCoins() < item['price']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金币不足！')));
      return;
    }
    
    setState(() {
      DataManager.addCoins(-(item['price'] as int));
      // 默认放在中间位置
      final idx = HomeData.placedItems.length;
      HomeData.addItem(item, 150.0 + (idx % 3) * 60, 200.0 + (idx ~/ 3) * 60);
    });
    HomeData.saveItems();
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('购买了 ${item['name']}！')));
  }
  
  void _showItemOptions(int uid) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                HomeData.removeItem(uid);
                HomeData.saveItems();
                setState(() {});
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 签到页面 ====================
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final canSignIn = DataManager.canSignIn();
    final signInDays = DataManager.getSignInDays();
    final lastSignIn = DataManager.getLastSignIn();
    final coins = DataManager.getCoins();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('每日签到', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 金币显示
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber[400]!, Colors.amber[600]!]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 10),
                  Text('$coins', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // 签到卡片
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('连续签到', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$signInDays', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const Text(' 天', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (lastSignIn.isNotEmpty)
                    Text('上次签到: $lastSignIn', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canSignIn ? () async {
                        final result = await DataManager.signIn();
                        if (result['success'] && mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('签到成功! 🎉'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('+${result['coins']} 金币', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                                  if (result['bonus'] > 0) Text('+${result['bonus']} 连续签到奖励!', style: const TextStyle(color: Colors.red)),
                                  Text('连续 ${result['days']} 天', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                              actions: [TextButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('确定'))],
                            ),
                          );
                          setState(() {});
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSignIn ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(canSignIn ? '立即签到' : '明天再来', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 签到奖励说明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('签到奖励', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildRewardItem('基础奖励', '10 + 连续天数 × 5 金币'),
                  _buildRewardItem('连续7天', '额外 100 金币'),
                  _buildRewardItem('连续30天', '额外 500 金币'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardItem(String title, String desc) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text('• ', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(desc, style: TextStyle(color: Colors.grey[500])),
      ],
    ),
  );
}

// ==================== 成就页面 ====================
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final achievements = DataManager.getAchievements();
    final unlocked = achievements.where((a) => a['unlocked'] == true).length;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('成就', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 进度条
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('成就进度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$unlocked / ${achievements.length}', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: unlocked / achievements.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          // 成就列表
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = ach['unlocked'] == true;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: isUnlocked ? Border.all(color: Colors.orange, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ach['icon'], style: TextStyle(fontSize: 32, color: isUnlocked ? null : Colors.grey)),
                      const SizedBox(height: 8),
                      Text(ach['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey)),
                      const SizedBox(height: 4),
                      Text(ach['desc'], style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
                      if (isUnlocked) ...[
                        const SizedBox(height: 4),
                        const Text('✅ 已完成', style: TextStyle(fontSize: 10, color: Colors.green)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 调试页面 ====================
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  Map<String, dynamic> _rawDbData = {};
  
  @override
  void initState() {
    super.initState();
    _loadRawData();
  }
  
  Future<void> _loadRawData() async {
    final data = await DataManager.getRawUserData();
    if (mounted) {
      setState(() => _rawDbData = data);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final nickname = DataManager.getNickname();
    final coins = DataManager.getCoins();
    final theme = DataManager.getCurrentTheme();
    final signInDays = DataManager.getSignInDays();
    final lastSignIn = DataManager.getLastSignIn();
    final pets = DataManager.getPets();
    final homeItems = HomeData.placedItems;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('调试信息', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 数据库原始数据
            _buildSection('数据库原始数据', [
              {'key': 'coins', 'value': '${_rawDbData['coins']}'},
              {'key': 'lastSignIn', 'value': '${_rawDbData['lastSignIn']}'},
              {'key': 'signInDays', 'value': '${_rawDbData['signInDays']}'},
              {'key': 'theme', 'value': '${_rawDbData['theme']}'},
            ]),
            ElevatedButton(onPressed: _loadRawData, child: const Text('刷新数据库数据')),
            const SizedBox(height: 16),
            _buildSection('内存数据', [
              {'key': '昵称', 'value': nickname},
              {'key': '主题', 'value': '$theme'},
              {'key': '金币', 'value': '$coins'},
            ]),
            _buildSection('签到数据', [
              {'key': '连续天数', 'value': '$signInDays'},
              {'key': '上次签到', 'value': lastSignIn.isEmpty ? '未签到' : lastSignIn},
            ]),
            _buildSection('宠物数据', [
              {'key': '宠物数量', 'value': '${pets.length}'},
              ...pets.asMap().entries.map((e) => {'key': '宠物${e.key+1}', 'value': '${e.value['name']} (${e.value['type']})'}),
            ]),
            _buildSection('家园数据', [
              {'key': '家具数量', 'value': '${homeItems.length}'},
              ...homeItems.asMap().entries.map((e) => {'key': '家具${e.key+1}', 'value': '${e.value['name']}'}),
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Map<String, String>> items) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('${item['key']}: ', style: TextStyle(color: Colors.grey[600])),
              Expanded(child: Text(item['value'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
        )),
      ],
    ),
  );
}

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
        title: Text('主题设置', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('选择主题风格', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          // 保存按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    print('=== 点击保存: _selectedTheme=$_selectedTheme ===');
                    await DataManager.setTheme(_selectedTheme);
                    // 实时刷新主题
                    StarPetApp.updateTheme(_selectedTheme);
                    // 验证保存
                    final saved = DataManager.getCurrentTheme();
                    print('=== 保存后验证: saved=$saved ===');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已保存为 ${_themes[_selectedTheme]['name']} (index: $_selectedTheme)'), duration: const Duration(seconds: 1)),
                      );
                      Future.delayed(const Duration(milliseconds: 500), () => Navigator.pop(context));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themes[_selectedTheme]['primary'] as Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('保存主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 消息通知页面 ====================
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('消息通知', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitch('接收推送通知', '开启后接收新消息提醒', _pushEnabled, (v) => setState(() => _pushEnabled = v)),
          _buildSwitch('声音', '消息提示音', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
          _buildSwitch('震动', '消息震动提醒', _vibrateEnabled, (v) => setState(() => _vibrateEnabled = v)),
        ],
      ),
    );
  }
  
  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ==================== 帮助与反馈页面 ====================
class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('帮助与反馈', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQ('如何添加宠物?', '进入"我的"页面，点击"我的宠物"，然后点击+按钮添加'),
          _buildFAQ('如何修改昵称?', '点击头像区域的昵称即可编辑'),
          _buildFAQ('什么是云养宠?', '远程关注其他用户的宠物'),
          _buildFAQ('数据会自动保存吗?', '是的，所有数据会自动保存到本地'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('反馈功能开发中...')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('提交反馈', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ==================== 关于我们页面 ====================
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});
  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool _hasUpdate = false;
  bool _checking = false;
  String _latestVersion = '';
  
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }
  
  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    final updateInfo = await OTAUpdater.checkUpdate();
    if (updateInfo != null) {
      final serverVersion = updateInfo['versionCode'] ?? 1;
      if (serverVersion > OTAUpdater.currentVersionCode) {
        setState(() {
          _hasUpdate = true;
          _latestVersion = updateInfo['version'] ?? '新版本';
        });
      }
    }
    setState(() => _checking = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('关于我们', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _checking 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
            onPressed: _checkUpdate,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFF69B4), Color(0xFF9370DB)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 50))),
                ),
                if (_hasUpdate)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('星宠', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('版本 ${OTAUpdater.currentVersion} | 主题: ${StarPetApp.currentThemeIndex}', style: TextStyle(color: Colors.grey)),
            if (_hasUpdate) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showUpdateDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text('$_latestVersion 可更新', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text('星宠是一款专为宠物爱好者打造的社交应用，在这里你可以记录宠物的成长，分享养宠乐趣。', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 40),
            Text('© 2026 StarPet', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
  
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('发现新版本'),
        content: Text('最新版本: $_latestVersion\n是否下载更新?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
          TextButton(
            onPressed: () {
              OTAUpdater.downloadUpdate(context);
              Navigator.pop(context);
            },
            child: Text('立即更新'),
          ),
        ],
      ),
    );
  }
}
