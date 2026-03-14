import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path_pkg;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'storage_manager.dart';
import 'models/theme.dart';
import 'utils/constants.dart';
import 'services/data_manager.dart';
import 'services/ota_updater.dart';
import 'services/home_data.dart';
import 'pages/theme_settings_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/achievements_page.dart';
import 'pages/about_us_page.dart';
import 'pages/notifications_page.dart';
import 'pages/help_feedback_page.dart';
import 'pages/debug_page.dart';
import 'pages/blacklist_page.dart';
import 'pages/recommend_mall_page.dart';
import 'pages/pet_mall_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 直接启动应用，后台加载数据
  DataManager.init();
  OTAUpdater.checkUpdateOnStart();
  
  runApp(const StarPetApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }
  
  Future<void> _initApp() async {
    await DataManager.init();
    OTAUpdater.checkUpdateOnStart();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StarPetApp()));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              const Text('星宠', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text('加载中...', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 宠物友好商场推荐表单 ====================
class RecommendMallPage extends StatefulWidget {
  const RecommendMallPage({super.key});
  @override
  State<RecommendMallPage> createState() => _RecommendMallPageState();
}

class _RecommendMallPageState extends State<RecommendMallPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedCity = '杭州';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('推荐商场', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('基本信息', [
            _buildTextField('商场名称', _nameController, '请输入商场名称'),
            _buildTextField('详细地址', _addressController, '请输入详细地址'),
            _buildTextField('联系电话', _phoneController, '请输入联系电话'),
          ]),
          const SizedBox(height: 20),
          _buildSection('推荐理由', [
            _buildTextField('推荐理由', _reasonController, '请描述为什么推荐这个商场', maxLines: 4),
          ]),
          const SizedBox(height: 20),
          _buildSection('所在城市', [
            Wrap(
              spacing: 12,
              children: [
                _buildCityChip('杭州'),
                _buildCityChip('南京'),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('提交后需要10人投票支持，达到5人支持后将展示在商场列表中', style: TextStyle(color: Colors.orange[800], fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildCityChip(String city) {
    final selected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE91E63) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  void _submit() {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty || _phoneController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ 提交成功'),
        content: const Text('感谢您的推荐！等待其他用户投票支持。'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('知道了'))],
      ),
    );
  }
}

// ==================== 宠物友好商场页面 ====================
class PetMallPage extends StatefulWidget {
  const PetMallPage({super.key});
  @override
  State<PetMallPage> createState() => _PetMallPageState();
}

class _PetMallPageState extends State<PetMallPage> {
  String _selectedCity = '杭州';
  Position? _userPosition;
  bool _locationLoading = true;
  
  final List<Map<String, dynamic>> _malls = [
    {'name': '宠物之星', 'city': '杭州', 'address': '西湖区文一路100号', 'phone': '0571-88888888', 'rating': 4.8, 'tags': ['宠物食品', '宠物玩具'], 'lat': 30.2741, 'lng': 120.1551},
    {'name': '萌宠之家', 'city': '杭州', 'address': '拱墅区湖墅南路200号', 'phone': '0571-87777777', 'rating': 4.6, 'tags': ['宠物美容', '宠物寄养'], 'lat': 30.3120, 'lng': 120.1650},
    {'name': '汪星人乐园', 'city': '杭州', 'address': '滨江区江南大道500号', 'phone': '0571-86666666', 'rating': 4.9, 'tags': ['宠物游泳', '宠物培训'], 'lat': 30.2084, 'lng': 120.2093},
    {'name': '喵星人工作室', 'city': '杭州', 'address': '上城区平海路150号', 'phone': '0571-85555555', 'rating': 4.7, 'tags': ['宠物美容', '宠物摄影'], 'lat': 30.2489, 'lng': 120.1658},
    {'name': '宠物医院', 'city': '南京', 'address': '鼓楼区中山路200号', 'phone': '025-83333333', 'rating': 4.8, 'tags': ['宠物医疗', '疫苗'], 'lat': 32.0603, 'lng': 118.7969},
    {'name': '爱宠宠物店', 'city': '南京', 'address': '秦淮区夫子庙街50号', 'phone': '025-82222222', 'rating': 4.5, 'tags': ['宠物食品', '宠物玩具'], 'lat': 32.0170, 'lng': 118.7876},
    {'name': '萌宠王国', 'city': '南京', 'address': '玄武区长江路100号', 'phone': '025-81111111', 'rating': 4.7, 'tags': ['宠物美容', '宠物寄养'], 'lat': 32.0603, 'lng': 118.7969},
    {'name': '汪汪宠物生活馆', 'city': '南京', 'address': '建邺区河西大街300号', 'phone': '025-80000000', 'rating': 4.6, 'tags': ['宠物游泳', '宠物培训'], 'lat': 32.0650, 'lng': 118.7780},
  ];
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _locationLoading = false); return; }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() => _userPosition = pos);
      }
    } catch(e) {
      print('获取位置失败: $e');
    }
    setState(() => _locationLoading = false);
  }
  
  double? _getDistance(double lat, double lng) {
    if (_userPosition == null) return null;
    return Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, lat, lng) / 1000;
  }
  
  List<Map<String, dynamic>> get _filteredMalls {
    return _malls.where((m) => m['city'] == _selectedCity).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('宠物友好商场', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildCityChip('杭州'),
                const SizedBox(width: 12),
                _buildCityChip('南京'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMalls.length,
              itemBuilder: (ctx, i) => _buildMallCard(_filteredMalls[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendMallPage())),
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildCityChip(String city) {
    final selected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF69B4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildMallCard(Map<String, dynamic> mall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商场图片占位
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 40, color: Colors.grey),
                  const SizedBox(height: 4),
                  Text('${mall['name']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mall['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Text('⭐ ', style: TextStyle(color: Colors.orange, fontSize: 14)),
                            Text('${mall['rating']}', style: const TextStyle(color: Colors.orange, fontSize: 14)),
                            const SizedBox(width: 8),
                            ...mall['tags'].map<Widget>((t) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFF69B4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFFFF69B4))),
                            )),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  GestureDetector(
                    onTap: () => _showLocation(mall['address']),
                    child: Row(children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF4CAF50)), 
                      const SizedBox(width: 4), 
                      Text(_locationLoading ? '加载中...' : (_getDistance(mall['lat'], mall['lng']) != null ? '${_getDistance(mall['lat'], mall['lng'])!.toStringAsFixed(1)}km' : '查看位置'), style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(width: 24),
                  Row(children: [const Icon(Icons.phone, size: 16, color: Color(0xFF2196F3)), const SizedBox(width: 4), Text(mall['phone'], style: const TextStyle(color: Color(0xFF2196F3)))]),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLocation(String address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📍 商户位置'),
        content: Text(address),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }
}

// ==================== 宠物友好草坪页面 ====================
// ==================== 宠物友好草坪推荐表单 ====================
class RecommendLawnPage extends StatefulWidget {
  const RecommendLawnPage({super.key});
  @override
  State<RecommendLawnPage> createState() => _RecommendLawnPageState();
}

class _RecommendLawnPageState extends State<RecommendLawnPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedCity = '杭州';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('推荐草坪', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('基本信息', [
            _buildTextField('公园名称', _nameController, '请输入公园名称'),
            _buildTextField('详细地址', _addressController, '请输入详细地址'),
          ]),
          const SizedBox(height: 20),
          _buildSection('推荐理由', [
            _buildTextField('推荐理由', _reasonController, '请描述为什么推荐这个草坪', maxLines: 4),
          ]),
          const SizedBox(height: 20),
          _buildSection('所在城市', [
            Wrap(
              spacing: 12,
              children: [
                _buildCityChip('杭州'),
                _buildCityChip('南京'),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('提交后需要10人投票支持，达到5人支持后将展示在草坪列表中', style: TextStyle(color: Colors.orange[800], fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildCityChip(String city) {
    final selected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8BC34A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  void _submit() {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ 提交成功'),
        content: const Text('感谢您的推荐！等待其他用户投票支持。'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('知道了'))],
      ),
    );
  }
}

class PetLawnPage extends StatefulWidget {
  const PetLawnPage({super.key});
  @override
  State<PetLawnPage> createState() => _PetLawnPageState();
}

class _PetLawnPageState extends State<PetLawnPage> {
  String _selectedCity = '杭州';
  Position? _userPosition;
  bool _locationLoading = true;
  
  final List<Map<String, dynamic>> _lawns = [
    {'name': '西湖公园', 'city': '杭州', 'address': '西湖区西湖风景名胜区', 'rating': 4.9, 'tags': ['草坪大', '狗狗多', '免费'], 'lat': 30.2468, 'lng': 120.1486, 'hours': '全天'},
    {'name': '钱江新城公园', 'city': '杭州', 'address': '上城区钱江新城', 'rating': 4.7, 'tags': ['设施完善', '有饮水点'], 'lat': 30.2431, 'lng': 120.2105, 'hours': '6:00-22:00'},
    {'name': '滨江公园', 'city': '杭州', 'address': '滨江区江南大道', 'rating': 4.6, 'tags': ['跑道', '夜间开放'], 'lat': 30.2084, 'lng': 120.2093, 'hours': '全天'},
    {'name': '白鹭湾湿地公园', 'city': '杭州', 'address': '余杭区白鹭湾', 'rating': 4.8, 'tags': ['环境好', '野餐区'], 'lat': 30.3412, 'lng': 120.0987, 'hours': '6:00-20:00'},
    {'name': '玄武湖公园', 'city': '南京', 'address': '玄武区玄武门', 'rating': 4.9, 'tags': ['历史悠久', '草坪大'], 'lat': 32.0603, 'lng': 118.7969, 'hours': '6:00-22:00'},
    {'name': '中山陵风景区', 'city': '南京', 'address': '玄武区钟山风景区', 'rating': 4.8, 'tags': ['空气好', '爬山'], 'lat': 32.0650, 'lng': 118.8596, 'hours': '6:30-18:30'},
    {'name': '绿博园', 'city': '南京', 'address': '建邺区扬子江大道', 'rating': 4.7, 'tags': ['植物多', '遛狗圣地'], 'lat': 32.0187, 'lng': 118.7298, 'hours': '8:00-18:00'},
    {'name': '紫金山公园', 'city': '南京', 'address': '玄武区钟山', 'rating': 4.6, 'tags': ['自然环境', '登山'], 'lat': 32.0650, 'lng': 118.8780, 'hours': '全天'},
  ];
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _locationLoading = false); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() => _userPosition = pos);
      }
    } catch(e) { print('获取位置失败: $e'); }
    setState(() => _locationLoading = false);
  }
  
  double? _getDistance(double lat, double lng) {
    if (_userPosition == null) return null;
    return Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, lat, lng) / 1000;
  }
  
  List<Map<String, dynamic>> get _filteredLawns => _lawns.where((l) => l['city'] == _selectedCity).toList();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('宠物友好草坪', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildCityChip('杭州'),
                const SizedBox(width: 12),
                _buildCityChip('南京'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredLawns.length,
              itemBuilder: (ctx, i) => _buildLawnCard(_filteredLawns[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendLawnPage())),
        backgroundColor: const Color(0xFF8BC34A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildCityChip(String city) {
    final selected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8BC34A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildLawnCard(Map<String, dynamic> lawn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Text('🌿', style: TextStyle(fontSize: 50))),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lawn['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text('⭐ ${lawn['rating']}', style: const TextStyle(color: Colors.orange)),
                            const SizedBox(width: 8),
                            ...lawn['tags'].map<Widget>((t) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF8BC34A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF8BC34A))),
                            )),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lawn['hours'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showLocation(lawn['address']),
                    child: Row(children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Text(_locationLoading ? '加载中...' : (_getDistance(lawn['lat'], lawn['lng']) != null ? '${_getDistance(lawn['lat'], lawn['lng'])!.toStringAsFixed(1)}km' : '查看位置'), style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLocation(String address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📍 公园位置'),
        content: Text(address),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了'))],
      ),
    );
  }
}

// ==================== 投毒点避雷页面 ====================
class BlacklistPage extends StatefulWidget {
  const BlacklistPage({super.key});
  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  String _selectedCity = '杭州';
  
  final List<Map<String, dynamic>> _blacklist = [
    {'name': 'xx宠物店', 'city': '杭州', 'address': '西湖区xxx路', 'reason': '疑似投毒', 'time': '2026-03'},
    {'name': 'xx公园', 'city': '杭州', 'address': '拱墅区xxx', 'reason': '有人投毒', 'time': '2026-02'},
    {'name': 'xx宠物医院', 'city': '南京', 'address': '鼓楼区xxx', 'reason': '无良医生', 'time': '2026-03'},
  ];
  
  List<Map<String, dynamic>> get _filtered => _blacklist.where((b) => b['city'] == _selectedCity).toList();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('投毒点避雷', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildChip('杭州'),
                const SizedBox(width: 12),
                _buildChip('南京'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _buildCard(_filtered[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFFFF5722),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildChip(String city) {
    final sel = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFFF5722) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Text(item['time'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('📍 ${item['address']}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text('❌ ${item['reason']}', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
  
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 举报须知'),
        content: const Text('请提供准确信息，文明举报'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('感谢您的举报'))); }, child: const Text('知道了')),
        ],
      ),
    );
  }
}

class StarPetApp extends StatefulWidget {
  const StarPetApp({super.key});

  // 主题配置 - 代理到 AppTheme
  static List<Map<String, dynamic>> get themes => AppTheme.themes;
  static int get currentThemeIndex => AppTheme.currentThemeIndex;
  static Color get primaryColor => AppTheme.primaryColor;
  static Color get secondaryColor => AppTheme.secondaryColor;
  static Color get backgroundColor => AppTheme.backgroundColor;
  static Color get textColor => AppTheme.textColor;
  static Color get textSecondary => AppTheme.textSecondary;
  static Color get groundTop => AppTheme.groundTop;
  static Color get groundBottom => AppTheme.groundBottom;
  static Color get skyTop => AppTheme.skyTop;
  static Color get skyBottom => AppTheme.skyBottom;
  static void updateTheme(int index) => AppTheme.updateTheme(index);

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
    
    AppTheme.setThemeIndex(savedTheme);
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
                      'Lv.${DataManager.getSignInDays() ~/ 7 + 1}',
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
    final pets = DataManager.getPets();
    // 无宠物时显示添加提示
    if (pets.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPetPage())),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StarPetApp.primaryColor.withValues(alpha: 0.3), style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: StarPetApp.primaryColor, size: 28),
              const SizedBox(width: 12),
              Text('添加你的第一只宠物', style: TextStyle(color: StarPetApp.primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '同城服务',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StarPetApp.textColor,
                    ),
                  ),
                  // 右侧按钮：跳转到新服务页
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewServicePage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: StarPetApp.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '新服务',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                        ],
                      ),
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
                    '🛒', 
                    '宠物友好商场', 
                    '附近宠物友好商户',
                    const Color(0xFFE91E63),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetMallPage()),
                    ),
                  ),
                  _buildServiceCard(
                    '🌳', 
                    '宠物友好草坪', 
                    '城市遛狗好去处',
                    const Color(0xFF8BC34A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetLawnPage()),
                    ),
                  ),
                  _buildServiceCard(
                    '⚠️', 
                    '投毒点避雷', 
                    '曝光不良商家',
                    const Color(0xFFFF5722),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlacklistPage()),
                    ),
                  ),
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

  Widget _buildServiceCard(String emoji, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  _buildDeviceCard(
                    '🚽', 
                    '智能猫砂盆', 
                    '未连接',
                    false,
                  ),
                  _buildDeviceCard(
                    '🍚', 
                    '智能喂食器', 
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
            // 宠物健康相关（宠物社交、疫苗提醒、健康记录）
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('宠物健康', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            ),
            _buildMenuItem(Icons.forum, '宠物社交', '分享萌宠动态', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PetSocialPage()));
            }),
            _buildMenuItem(Icons.vaccines, '疫苗提醒', '疫苗接种记录', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaccinePage()));
            }),
            _buildMenuItem(Icons.medical_services, '健康记录', '体重/体检/就诊', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthRecordPage()));
            }),
            const SizedBox(height: 12),
            _buildMenuItem(Icons.settings, '主题设置', '切换主题风格', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeSettingsPage()));
            }),
            _buildMenuItem(Icons.notifications, '消息通知', '推送消息设置', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }),
            _buildMenuItem(Icons.help, '帮助与反馈', '常见问题', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFeedbackPage()));
            }),
            _buildMenuItem(Icons.delete_sweep, '清理缓存', '释放存储空间', onTap: () async {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('清理缓存'),
                content: const Text('确定要清理缓存吗？'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                  TextButton(onPressed: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清理')));
                  }, child: const Text('确定')),
                ],
              ));
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetPage(petIndex: index))).then((_) => setState(() {}));
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
  int? breedId;
  List<Map<String, dynamic>> _breedsList = [];
  bool _loadingBreeds = true;
  bool _isSaving = false; // 防止重复提交
  final _nameController = TextEditingController();
  bool _showPetAnimation = false;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
    if (widget.petIndex != null) {
      final pet = DataManager.getPets()[widget.petIndex!];
      _nameController.text = pet['name'] ?? '';
      petType = pet['type'] as String?;
      gender = pet['gender'] as String?;
      breed = pet['breed'] as String?;
      color = pet['color'] as String?;
      feature = pet['feature'] as String?;
      breedId = pet['breed_id'] as int?;
    }
  }
  
  Future<void> _loadBreeds() async {
    // 使用本地品种数据
    setState(() {
      _breedsList = [
        {'id': 1, 'type': 'cat', 'name': '英国短毛猫'},
        {'id': 2, 'type': 'cat', 'name': '美国短毛猫'},
        {'id': 3, 'type': 'cat', 'name': '波斯猫'},
        {'id': 4, 'type': 'cat', 'name': '暹罗猫'},
        {'id': 5, 'type': 'cat', 'name': '布偶猫'},
        {'id': 6, 'type': 'cat', 'name': '缅因猫'},
        {'id': 7, 'type': 'cat', 'name': '苏格兰折耳猫'},
        {'id': 8, 'type': 'cat', 'name': '俄罗斯蓝猫'},
        {'id': 9, 'type': 'cat', 'name': '挪威森林猫'},
        {'id': 10, 'type': 'cat', 'name': '中华田园猫'},
        {'id': 11, 'type': 'dog', 'name': '金毛寻回犬'},
        {'id': 12, 'type': 'dog', 'name': '拉布拉多'},
        {'id': 13, 'type': 'dog', 'name': '柯基'},
        {'id': 14, 'type': 'dog', 'name': '哈士奇'},
        {'id': 15, 'type': 'dog', 'name': '萨摩耶'},
        {'id': 16, 'type': 'dog', 'name': '柴犬'},
        {'id': 17, 'type': 'dog', 'name': '边境牧羊犬'},
        {'id': 18, 'type': 'dog', 'name': '贵宾犬'},
        {'id': 19, 'type': 'dog', 'name': '比熊犬'},
        {'id': 20, 'type': 'dog', 'name': '中华田园犬'},
        {'id': 101, 'type': 'color', 'name': '白色'},
        {'id': 102, 'type': 'color', 'name': '黑色'},
        {'id': 103, 'type': 'color', 'name': '灰色'},
        {'id': 104, 'type': 'color', 'name': '橘色'},
        {'id': 105, 'type': 'color', 'name': '三花'},
        {'id': 106, 'type': 'color', 'name': '奶牛'},
        {'id': 107, 'type': 'color', 'name': '虎斑'},
        {'id': 108, 'type': 'color', 'name': '玳瑁'},
      ];
      _loadingBreeds = false;
    });
  }
  
  List<String> get _breeds {
    if (petType == null) return [];
    return _breedsList.where((b) => b['type'] == petType).map((b) => b['name'] as String).toList();
  }
  
  List<String> get _colors {
    return _breedsList.where((b) => b['type'] == 'color').map((b) => b['name'] as String).toList();
  }
  
  Map<int, String> get _breedMap {
    if (petType == null) return {};
    return {for (var b in _breedsList.where((b) => b['type'] == petType)) b['id'] as int: b['name'] as String};
  }

  Widget _buildCard(String emoji, String label, bool sel, VoidCallback tap) => GestureDetector(onTap: tap, child: Container(width: 150, height: 100, decoration: BoxDecoration(color: sel ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? Colors.black : Colors.grey[300]!)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: TextStyle(fontSize: 36)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 14, color: sel ? Colors.white : Colors.black))])));

  Future<void> _savePet() async {
    if (_isSaving) return; // 防止重复点击
    _isSaving = true;
    
    final name = _nameController.text.isEmpty ? '宠物${DataManager.getPets().length + 1}' : _nameController.text;
    final pet = {
      'name': name, 
      'type': petType ?? 'cat', 
      'gender': gender ?? 'female', 
      'color': color ?? '', 
      'breed': breed ?? '', 
      'feature': feature ?? '',
    };
    try {
      if (widget.petIndex != null) await DataManager.updatePet(widget.petIndex!, pet);
      else await DataManager.addPet(pet);
      if (mounted) {
        setState(() => _showPetAnimation = true);
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ 保存成功'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
      }
    } catch(e) {
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      _isSaving = false;
    }
  }

  Widget _buildAnim() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () { setState(() => _showPetAnimation = false); Navigator.pop(context, true); },
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
                if (gender != null) ...[_buildSectionTitle('3. 选择花色'), const SizedBox(height: 12), _loadingBreeds ? const CircularProgressIndicator() : _buildGrid(_colors, color, (c) => setState(() => color = c)), const SizedBox(height: 24)],
                if (gender != null && color != null) ...[_buildSectionTitle(widget.petIndex != null ? '4. 选择品种' : '5. 选择品种'), const SizedBox(height: 12), _loadingBreeds ? const CircularProgressIndicator() : _buildGrid(_breeds, breed, (b) { setState(() { breed = b; breedId = _breedMap.entries.firstWhere((e) => e.value == b).key; }); }), const SizedBox(height: 24)],
                if (breed != null && petType != null) ...[_buildSectionTitle(widget.petIndex != null ? '5. 选择特征' : '6. 选择特征'), const SizedBox(height: 12), _buildGrid(petType == 'cat' ? ['粘人', '高冷', '活泼', '安静', '贪吃', '好奇'] : ['忠诚', '活泼', '粘人', '护主', '贪玩', '安静'], feature, (f) => setState(() => feature = f)), const SizedBox(height: 24)],
                if (feature != null) SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isSaving ? null : _savePet, style: ElevatedButton.styleFrom(backgroundColor: _isSaving ? Colors.grey : Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_isSaving ? '保存中...' : (widget.petIndex != null ? '保存修改' : '保存'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
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
              DataManager.setUserData('nickname', _nicknameController.text.isEmpty ? '点击编辑昵称' : _nicknameController.text);
              final selectedNames = roles.where((r) => selectedRoles.contains(int.parse(r['id']!))).map((r) => r['name']!).toList();
              DataManager.setUserData('roles', selectedNames);
              try {
                final success = await DataManager.saveAndGetResult();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? '✅ 保存成功' : '❌ 保存失败'), backgroundColor: success ? Colors.green : Colors.red));
                  if (success) Future.delayed(Duration(milliseconds: 500), () => Navigator.pop(context, true));
                }
              } catch(e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 保存失败: $e'), backgroundColor: Colors.red));
                }
              }
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
  static const String baseUrl = 'http://100.115.16.2:8080';
  static const int currentVersionCode = 54;
  static const String currentVersion = '2.5.0';
  
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
                    
                    await DataManager.setTheme(_selectedTheme);
                    // 实时刷新主题
                    StarPetApp.updateTheme(_selectedTheme);
                    
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

// ==================== 新服务页面（空白，后续功能在此调试）====================
class NewServicePage extends StatefulWidget {
  const NewServicePage({super.key});
  @override
  State<NewServicePage> createState() => _NewServicePageState();
}

class _NewServicePageState extends State<NewServicePage> {
  int _selectedTab = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('新服务', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab 切换
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _buildTab(0, '宠物社交'),
                _buildTab(1, '疫苗提醒'),
                _buildTab(2, '健康记录'),
              ],
            ),
          ),
          // 内容
          Expanded(
            child: _selectedTab == 0 
              ? _buildSocialView()
              : _selectedTab == 1
                ? _buildVaccineView()
                : _buildHealthView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? StarPetApp.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
  
  // 宠物社交视图
  Widget _buildSocialView() {
    final posts = DataManager.getPosts();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('🐾 宠物社交', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('分享你和宠物的精彩瞬间', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发布功能开发中...')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text('发布动态', style: TextStyle(color: StarPetApp.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }
        final post = posts[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: StarPetApp.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('🐱', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('用户${i}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(post['time'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post['content'] ?? '', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('❤️ ${post['likes'] ?? 0}', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  Text('💬 评论', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 疫苗提醒视图
  Widget _buildVaccineView() {
    final vaccines = DataManager.getVaccines();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 标题卡片
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text('💉', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('疫苗提醒', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('守护宠物健康', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddVaccineDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.add, color: Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
        ),
        // 疫苗列表
        if (vaccines.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('💉', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                Text('暂无疫苗记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('点击右上角添加疫苗记录', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        else
          ...vaccines.map((v) => _buildVaccineCard(v)),
      ],
    );
  }
  
  Widget _buildVaccineCard(Map<String, dynamic> vaccine) {
    final isOverdue = vaccine['isOverdue'] == true;
    final isUpcoming = vaccine['isUpcoming'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue ? Border.all(color: Colors.red, width: 2) : (isUpcoming ? Border.all(color: Colors.orange, width: 2) : null),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.withValues(alpha: 0.1) : (isUpcoming ? Colors.orange.withValues(alpha: 0.1) : Color(0xFF4CAF50).withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('💉', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccine['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(vaccine['date'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red : (isUpcoming ? Colors.orange : Colors.green),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOverdue ? '已过期' : (isUpcoming ? '即将到期' : '已接种'),
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddVaccineDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('添加疫苗记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '疫苗名称',
                hintText: '如：狂犬疫苗',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: '接种日期',
                hintText: '如：2026-03-14',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                DataManager.addVaccine({
                  'name': nameController.text,
                  'date': dateController.text,
                });
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text('添加'),
          ),
        ],
      ),
    );
  }
  
  // 健康记录视图
  Widget _buildHealthView() {
    final records = DataManager.getHealthRecords();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 标题卡片
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF03A9F4)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text('🏥', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('健康记录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('记录宠物成长健康', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddHealthDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.add, color: Color(0xFF2196F3)),
                ),
              ),
            ],
          ),
        ),
        // 记录列表
        if (records.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('🏥', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                Text('暂无健康记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('点击右上角添加健康记录', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        else
          ...records.map((r) => _buildHealthCard(r)),
      ],
    );
  }
  
  Widget _buildHealthCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getHealthEmoji(record['type']), style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(record['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Text(record['date'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          if (record['detail'] != null && record['detail'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(record['detail'].toString(), style: TextStyle(color: Colors.grey[600])),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              ...((record['tags'] as List?)?.map((t) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Color(0xFF2196F3).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(t.toString(), style: TextStyle(fontSize: 11, color: Color(0xFF2196F3))),
              )) ?? []),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getHealthEmoji(String? type) {
    switch (type) {
      case 'weight': return '⚖️';
      case 'checkup': return '🏥';
      case 'medicine': return '💊';
      case 'illness': return '🤒';
      case 'beauty': return '✂️';
      default: return '📋';
    }
  }
  
  void _showAddHealthDialog(BuildContext context) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    String selectedType = 'checkup';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('添加健康记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTypeChip('⚖️ 体重', 'weight', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildTypeChip('🏥 体检', 'checkup', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildTypeChip('💊 喂药', 'medicine', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildTypeChip('🤒 就诊', 'illness', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildTypeChip('✂️ 美容', 'beauty', selectedType, (t) => setDialogState(() => selectedType = t)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '标题',
                    hintText: '如：体重测量',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '详情',
                    hintText: '记录详细信息...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  DataManager.addHealthRecord({
                    'type': selectedType,
                    'title': titleController.text,
                    'detail': detailController.text,
                    'date': DateTime.now().toString().substring(0, 10),
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(String label, String type, String selected, Function(String) onTap) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2196F3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
      ),
    );
  }
}

// ==================== 宠物社交页面 ====================
class PetSocialPage extends StatefulWidget {
  const PetSocialPage({super.key});
  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  @override
  Widget build(BuildContext context) {
    final posts = DataManager.getPosts();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('宠物社交', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: StarPetApp.primaryColor),
            onPressed: () => _showPostDialog(context),
          ),
        ],
      ),
      body: posts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🐾', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text('暂无动态', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('点击右上角发布第一条动态', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (ctx, i) {
              final post = posts[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [StarPetApp.primaryColor, StarPetApp.secondaryColor]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('🐱', style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('用户${i + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(post['time'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post['content'] ?? '', style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('❤️ ${post['likes'] ?? 0}', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        Text('💬 评论', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
  
  void _showPostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('发布动态'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '分享你和宠物的故事...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                DataManager.addPost({
                  'content': controller.text,
                  'time': DateTime.now().toString().substring(0, 16),
                  'likes': 0,
                });
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text('发布'),
          ),
        ],
      ),
    );
  }
}

// ==================== 疫苗提醒页面 ====================
class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});
  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  @override
  Widget build(BuildContext context) {
    final vaccines = DataManager.getVaccines();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('疫苗提醒', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: StarPetApp.primaryColor),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: vaccines.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text('暂无疫苗记录', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('点击右上角添加疫苗记录', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaccines.length,
            itemBuilder: (ctx, i) {
              final v = vaccines[i];
              final isOverdue = v['isOverdue'] == true;
              final isUpcoming = v['isUpcoming'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isOverdue ? Border.all(color: Colors.red, width: 2) : (isUpcoming ? Border.all(color: Colors.orange, width: 2) : null),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red.withValues(alpha: 0.1) : (isUpcoming ? Colors.orange.withValues(alpha: 0.1) : Color(0xFF4CAF50).withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('💉', style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(v['date'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red : (isUpcoming ? Colors.orange : Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOverdue ? '已过期' : (isUpcoming ? '即将到期' : '已接种'),
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
  
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('添加疫苗记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '疫苗名称',
                hintText: '如：狂犬疫苗',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: '接种日期',
                hintText: '如：2026-03-14',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                DataManager.addVaccine({
                  'name': nameController.text,
                  'date': dateController.text,
                });
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text('添加'),
          ),
        ],
      ),
    );
  }
}

// ==================== 健康记录页面 ====================
class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});
  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  @override
  Widget build(BuildContext context) {
    final records = DataManager.getHealthRecords();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('健康记录', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: StarPetApp.primaryColor),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: records.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏥', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text('暂无健康记录', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('点击右上角添加健康记录', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (ctx, i) {
              final r = records[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_getEmoji(r['type']), style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(r['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Text(r['date'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    if (r['detail'] != null && r['detail'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(r['detail'].toString(), style: TextStyle(color: Colors.grey[600])),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }
  
  String _getEmoji(String? type) {
    switch (type) {
      case 'weight': return '⚖️';
      case 'checkup': return '🏥';
      case 'medicine': return '💊';
      case 'illness': return '🤒';
      case 'beauty': return '✂️';
      default: return '📋';
    }
  }
  
  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    String selectedType = 'checkup';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('添加健康记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip('⚖️', 'weight', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('🏥', 'checkup', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('💊', 'medicine', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('🤒', 'illness', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('✂️', 'beauty', selectedType, (t) => setDialogState(() => selectedType = t)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '详情',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  DataManager.addHealthRecord({
                    'type': selectedType,
                    'title': titleController.text,
                    'detail': detailController.text,
                    'date': DateTime.now().toString().substring(0, 10),
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChip(String emoji, String type, String selected, Function(String) onTap) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2196F3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$emoji', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
