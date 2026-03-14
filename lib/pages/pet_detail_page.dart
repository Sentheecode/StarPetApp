import 'package:flutter/material.dart';
import '../services/data_manager.dart';

// ==================== 宠物详情页面 ====================
class PetDetailPage extends StatelessWidget {
  final int petIndex;
  const PetDetailPage({super.key, required this.petIndex});

  @override
  Widget build(BuildContext context) {
    final pets = DataManager.getPets();
    if (petIndex >= pets.length) {
      return Scaffold(appBar: AppBar(title: const Text('宠物详情')), body: const Center(child: Text('宠物不存在')));
    }
    final pet = pets[petIndex];
    final isCat = pet['type'] == 'cat';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(pet['name'] ?? '宠物详情', style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          // 编辑按钮暂时禁用，等 AddPetPage 拆分完成后再启用
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Colors.black),
          //   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddPetPage(petIndex: petIndex))),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isCat ? [const Color(0xFFFF69B4), const Color(0xFF9370DB)] : [const Color(0xFF87CEEB), const Color(0xFF4169E1)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Center(child: Text(isCat ? '🐱' : '🐕', style: const TextStyle(fontSize: 60))),
            ),
            const SizedBox(height: 16),
            Text(pet['name'] ?? '未命名', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
            _buildInfoCard([
              {'icon': Icons.pets, 'label': '类型', 'value': isCat ? '猫咪' : '狗狗'},
              {'icon': Icons.palette, 'label': '毛色', 'value': pet['color'] ?? '未知'},
              {'icon': Icons.star, 'label': '特点', 'value': (pet['features'] as List?)?.join('、') ?? '暂无'},
              {'icon': Icons.calendar_today, 'label': '添加时间', 'value': pet['createdAt']?.toString().substring(0, 10) ?? '未知'},
            ]),
            const SizedBox(height: 20),
            _buildGrowthCard(),
            const SizedBox(height: 20),
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
          Text(item['label'] as String, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(item['value'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
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
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)), child: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey))),
      const SizedBox(width: 12),
      Expanded(child: Text(content)),
    ]),
  );
}
