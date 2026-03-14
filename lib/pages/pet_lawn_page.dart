import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'recommend_lawn_page.dart';

// ==================== 宠物友好草坪页面 ====================
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
}
