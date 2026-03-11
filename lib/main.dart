import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ==================== 数据管理 ====================
class DataManager {
  static Map<String, dynamic> _userData = {'nickname': '点击编辑昵称', 'roles': <String>[]};
  static List<Map<String, dynamic>> _petsData = [];
  static List<Map<String, dynamic>> _postsData = [
    {'content': '今天带豆豆去公园玩，它好开心啊！🐕', 'time': '2026-03-11 15:30', 'likes': 12},
    {'content': '咪咪今天第一次尝试吃猫罐头，太可爱了！🐱', 'time': '2026-03-10 10:20', 'likes': 25},
    {'content': '新买的宠物玩具到了，俩孩子玩得不亦乐乎', 'time': '2026-03-09 18:45', 'likes': 8},
  ];
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadData(); // 加载保存的数据
  }
  
  // 加载数据
  static Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 加载用户数据
      final nickname = prefs.getString('nickname');
      if (nickname != null) _userData['nickname'] = nickname;
      final roles = prefs.getStringList('roles');
      if (roles != null) _userData['roles'] = roles;
      // 加载宠物数据
      final petsJson = prefs.getString('pets');
      if (petsJson != null) {
        final List<dynamic> decoded = jsonDecode(petsJson);
        _petsData = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('加载数据失败: $e');
    }
  }
  
  // 保存数据
  static Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', _userData['nickname'] ?? '点击编辑昵称');
      await prefs.setStringList('roles', List<String>.from(_userData['roles'] ?? []));
      await prefs.setString('pets', jsonEncode(_petsData));
    } catch (e) {
      print('保存数据失败: $e');
    }
  }
  
  static Map<String, dynamic> getUserData() => _userData;
  static void setNickname(String name) { _userData['nickname'] = name; _saveData(); }
  static void setRoles(List<String> roles) { _userData['roles'] = roles; _saveData(); }
  static String getNickname() => _userData['nickname'] ?? '点击编辑昵称';
  static List<String> getRoles() => List<String>.from(_userData['roles'] ?? []);
  static List<Map<String, dynamic>> getPets() => _petsData;
  static List<Map<String, dynamic>> getPosts() => _postsData;
  static void addPet(Map<String, dynamic> pet) { _petsData.add(pet); _saveData(); }
  static void updatePet(int index, Map<String, dynamic> pet) { if (index >= 0 && index < _petsData.length) { _petsData[index] = pet; _saveData(); } }
  static void deletePet(int index) { if (index >= 0 && index < _petsData.length) { _petsData.removeAt(index); _saveData(); } }
  static void addPost(Map<String, dynamic> post) => _postsData.insert(0, post);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.init();
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
                      child: const Text(
                        '♀ 雌性',
                        style: TextStyle(fontSize: 10, color: Colors.white),
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
            _buildMenuItem(Icons.home, '我的家园', '查看/编辑家园'),
            _buildMenuItem(Icons.settings, '主题设置', '切换主题风格'),
            _buildMenuItem(Icons.notifications, '消息通知', '推送消息设置'),
            _buildMenuItem(Icons.help, '帮助与反馈', '常见问题'),
            _buildMenuItem(Icons.info, '关于我们', '版本信息'),
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
              onTap: () {
                DataManager.deletePet(index);
                Navigator.pop(ctx);
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
                          Text('${(pet['gender'] ?? 'female') == 'female' ? '雌性' : '雄性'} · ${pet['feature'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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

  void _savePet() {
    final name = _nameController.text.isEmpty ? '宠物${DataManager.getPets().length + 1}' : _nameController.text;
    final pet = {'name': name, 'type': petType ?? 'cat', 'gender': gender ?? 'female', 'color': color ?? '', 'breed': breed ?? '', 'feature': feature ?? ''};
    if (widget.petIndex != null) DataManager.updatePet(widget.petIndex!, pet);
    else DataManager.addPet(pet);
    setState(() => _showPetAnimation = true);
  }

  Widget _buildAnim() => GestureDetector(onTap: () { setState(() => _showPetAnimation = false); Navigator.pop(context); }, child: Container(color: Colors.black.withValues(alpha: 0.8), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(petType == 'cat' ? '🐱' : '🐕', style: const TextStyle(fontSize: 80)), const SizedBox(height: 20), Text(_nameController.text.isEmpty ? '新宠物' : _nameController.text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 10), const Text('恭喜获得新宠物!', style: TextStyle(fontSize: 16, color: Colors.white70)), const SizedBox(height: 30), const Text('点击任意处关闭', style: TextStyle(fontSize: 14, color: Colors.white54))]))));

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
            onPressed: () {
              DataManager.setNickname(_nicknameController.text.isEmpty ? '点击编辑昵称' : _nicknameController.text);
              final selectedNames = roles.where((r) => selectedRoles.contains(int.parse(r['id']!))).map((r) => r['name']!).toList();
              DataManager.setRoles(selectedNames);
              Navigator.pop(context);
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
