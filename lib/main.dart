import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show Database;
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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY,
            nickname TEXT,
            roles TEXT,
            theme INTEGER DEFAULT 0
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
        await db.insert('user', {'id': 1, 'nickname': '点击编辑昵称', 'roles': ''});
      },
    );
  }
  
  static Future<void> init() async {
    await database;
    await _loadData();
  }
  
  // 加载数据
  static Future<void> _loadData() async {
    try {
      final db = await database;
      // 加载用户数据
      final userList = await db.query('user', where: 'id = ?', whereArgs: [1]);
      if (userList.isNotEmpty) {
        final user = userList.first;
        _userData['nickname'] = user['nickname'] ?? '点击编辑昵称';
        final rolesStr = user['roles'] as String? ?? '';
        _userData['roles'] = rolesStr.isEmpty ? <String>[] : rolesStr.split(',');
        // 加载主题
        _currentThemeIndex = user['theme'] as int? ?? 0;
      }
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
      // 保存用户数据
      await db.update(
        'user',
        {
          'nickname': _userData['nickname'] ?? '点击编辑昵称',
          'roles': (_userData['roles'] as List<String>).join(','),
          'theme': _currentThemeIndex,
        },
        where: 'id = ?',
        whereArgs: [1],
      );
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
  static int _currentThemeIndex = 0;
  static int getCurrentTheme() => _currentThemeIndex;
  static Future<void> setTheme(int index) async { _currentThemeIndex = index; await _saveData(); }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.init();
  // 启动时检测更新
  OTAUpdater.checkUpdateOnStart();
  runApp(const StarPetApp());
}

class StarPetApp extends StatelessWidget {
  const StarPetApp({super.key});

  // 苹果简约ins风主题
  static const Color primaryColor = Color(0xFF000000); // 黑色
  static const Color secondaryColor = Color(0xFF8E8E93); // 灰色
  static const Color backgroundColor = Color(0xFFF2F2F7); // 浅灰
  static const Color accentColor = Color(0xFF007AFF); // 蓝色
  static const Color textColor = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color groundTop = Color(0xFFE5E5EA);
  static const Color groundBottom = Color(0xFFD1D1D6);
  static const Color skyTop = Color(0xFFF2F2F7);
  static const Color skyBottom = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarPet - 星宠',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
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
        title: const Text('发现新版本!'),
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
            child: const Text('稍后再说'),
          ),
          TextButton(
            onPressed: () {
              OTAUpdater.downloadUpdate(context);
              Navigator.pop(context);
            },
            child: const Text('立即更新'),
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
      decoration: const BoxDecoration(
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
                child: const Icon(
                  Icons.pets,
                  color: StarPetApp.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
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
                  gradient: const LinearGradient(
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
                child: const Row(
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
                child: const Icon(
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
              gradient: const LinearGradient(
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
                style: const TextStyle(fontSize: 28),
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
                      style: const TextStyle(
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
                        style: const TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pets[0]['type'] == 'cat' ? '🐱' : '🐕'} ${pets[0]['breed']} · 1岁',
                  style: const TextStyle(
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
                    style: const TextStyle(
                      color: StarPetApp.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.pets, size: 16, color: StarPetApp.primaryColor),
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
              decoration: const BoxDecoration(
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
                decoration: const BoxDecoration(
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
                errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 72)),
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
                errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 56)),
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
                errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 40)),
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
                child: const Icon(
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
            style: const TextStyle(
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
              child: const Row(
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
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: StarPetApp.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
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
                  const Text(
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
                      child: const Icon(Icons.add, color: Colors.black, size: 24),
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
                  gradient: const LinearGradient(
                    colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(author.split(' ')[0], style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.split(' ')[1],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: StarPetApp.textColor,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 15,
              color: StarPetApp.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                stats,
                style: const TextStyle(
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
              child: const Row(
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
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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
                  gradient: const LinearGradient(
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
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
                          child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
            _buildMenuItem(Icons.settings, '主题设置', '切换主题风格', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeSettingsPage()));
            }),
            _buildMenuItem(Icons.notifications, '消息通知', '推送消息设置', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }),
            _buildMenuItem(Icons.help, '帮助与反馈', '常见问题', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFeedbackPage()));
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: StarPetApp.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: StarPetApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
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
        title: const Text('选择角色', style: TextStyle(color: Colors.black)),
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
                          Container(width: 60, height: 60, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: Center(child: Text(role['icon'], style: const TextStyle(fontSize: 30)))),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(role['desc'], style: TextStyle(fontSize: 13, color: Colors.grey[600]))])),
                          if (isSelected) Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 18)),
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
                  child: const Text('下一步', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            Text(pet['name'] ?? '宠物', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetPage(petIndex: index)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
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
        title: const Text('我的宠物', style: TextStyle(color: Colors.black)),
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
                    Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Center(child: Text((pet['type'] ?? 'cat') == 'cat' ? '🐱' : '🐕', style: const TextStyle(fontSize: 36)))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet['name'] ?? '宠物', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildCard(String emoji, String label, bool sel, VoidCallback tap) => GestureDetector(onTap: tap, child: Container(width: 150, height: 100, decoration: BoxDecoration(color: sel ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? Colors.black : Colors.grey[300]!)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: const TextStyle(fontSize: 36)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 14, color: sel ? Colors.white : Colors.black))])));

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
                                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B6B)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: const Text('★★★ 新宠物 ★★★', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                            child: Center(child: Text(petType == 'cat' ? '🐱' : '🐕', style: const TextStyle(fontSize: 80))),
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
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 10)]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text('${petType == 'cat' ? '猫咪' : '狗狗'} · ${gender == 'female' ? '雌性' : '雄性'}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                            child: const Text('✨ 恭喜获得新伙伴! ✨', style: TextStyle(fontSize: 20, color: Color(0xFFFFD700), fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                    const Text('点击任意处关闭', style: TextStyle(color: Colors.white38, fontSize: 14)),
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
              child: Text(['✨', '⭐', '🌟', '💫', '✦'][index % 5], style: const TextStyle(fontSize: 24)),
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: Text(widget.petIndex != null ? '编辑宠物' : '添加宠物', style: const TextStyle(color: Colors.black)), centerTitle: true),
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
                if (feature != null) SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _savePet, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(widget.petIndex != null ? '保存修改' : '保存', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
          if (_showPetAnimation) _buildAnim(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Widget _buildGrid(List<String> items, String? sel, Function(String) onTap) => Wrap(spacing: 8, runSpacing: 8, children: items.map((i) => GestureDetector(onTap: () => onTap(i), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: sel == i ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(i, style: TextStyle(color: sel == i ? Colors.white : Colors.black))))).toList());
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text('发布博文', style: TextStyle(color: Colors.black)), centerTitle: true, actions: [TextButton(onPressed: _publishPost, child: const Text('发布', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)))]),
      body: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _contentController, maxLines: null, minLines: 10, decoration: const InputDecoration(hintText: '分享你和宠物的故事...', border: InputBorder.none), style: const TextStyle(fontSize: 16))),
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
        title: const Text('编辑资料', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              await DataManager.setNickname(_nicknameController.text.isEmpty ? '点击编辑昵称' : _nicknameController.text);
              final selectedNames = roles.where((r) => selectedRoles.contains(int.parse(r['id']!))).map((r) => r['name']!).toList();
              await DataManager.setRoles(selectedNames);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('保存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('昵称', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          const Text('选择角色（可多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      child: Center(child: Text(role['icon']!, style: const TextStyle(fontSize: 24))),
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
  static const int currentVersionCode = 10;
  
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

// ==================== 我的家园页面 ====================
class HomeEditPage extends StatelessWidget {
  const HomeEditPage({super.key});
  
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
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('家园系统开发中...', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 10),
            Text('敬请期待!', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
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
          // 保存按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await DataManager.setTheme(_selectedTheme);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('主题已保存，重启APP生效'), duration: Duration(seconds: 2)),
                      );
                      Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
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
        title: const Text('消息通知', style: TextStyle(color: Colors.black)),
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
        title: const Text('帮助与反馈', style: TextStyle(color: Colors.black)),
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
            child: const Text('提交反馈', style: TextStyle(fontSize: 16)),
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
          Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
        title: const Text('关于我们', style: TextStyle(color: Colors.black)),
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
                    gradient: const LinearGradient(colors: [Color(0xFFFF69B4), Color(0xFF9370DB)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 50))),
                ),
                if (_hasUpdate)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('星宠', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('版本 ${OTAUpdater.currentVersionCode <= 9 ? '1.0.' + OTAUpdater.currentVersionCode.toString() : '1.0.' + OTAUpdater.currentVersionCode.toString()}', style: const TextStyle(color: Colors.grey)),
            if (_hasUpdate) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showUpdateDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text('$_latestVersion 可更新', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
        title: const Text('发现新版本'),
        content: Text('最新版本: $_latestVersion\n是否下载更新?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              OTAUpdater.downloadUpdate(context);
              Navigator.pop(context);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }
}
