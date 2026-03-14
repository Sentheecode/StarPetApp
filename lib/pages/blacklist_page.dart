import 'package:flutter/material.dart';

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
          Text('❌ ${item['reason']}', style: const TextStyle(color: Colors.red)),
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
