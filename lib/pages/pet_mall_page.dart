import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'recommend_mall_page.dart';

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
  
  void _showLocation(String address) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('地址: $address')));
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
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showLocation(mall['phone']),
                    child: Row(children: [
                      const Icon(Icons.phone, size: 16, color: Color(0xFF2196F3)), 
                      const SizedBox(width: 4), 
                      Text('联系商家', style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
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
