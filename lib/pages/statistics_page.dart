import 'package:flutter/material.dart';
import '../services/data_manager.dart';

// ==================== 数据统计页面 ====================
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = DataManager.getStatistics();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('数据统计', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 概览卡片
          _buildOverviewCard(stats),
          const SizedBox(height: 16),
          
          // 宠物统计
          _buildStatCard('🐾 宠物统计', [
            {'label': '宠物数量', 'value': '${stats['totalPets']}', 'icon': Icons.pets},
            {'label': '疫苗记录', 'value': '${stats['totalVaccines']}', 'icon': Icons.vaccines},
            {'label': '健康记录', 'value': '${stats['totalHealthRecords']}', 'icon': Icons.health_and_safety},
          ]),
          const SizedBox(height: 16),
          
          // 社交统计
          _buildStatCard('📱 社交统计', [
            {'label': '发布动态', 'value': '${stats['totalPosts']}', 'icon': Icons.post_add},
            {'label': '获得成就', 'value': '${stats['achievements']}/${stats['totalAchievements']}', 'icon': Icons.emoji_events},
          ]),
          const SizedBox(height: 16),
          
          // 签到统计
          _buildStatCard('📅 签到统计', [
            {'label': '连续签到', 'value': '${stats['signInDays']} 天', 'icon': Icons.calendar_today},
            {'label': '上次签到', 'value': '${stats['lastSignIn']}', 'icon': Icons.access_time},
          ]),
          const SizedBox(height: 16),
          
          // 金币统计
          _buildCoinCard(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF69B4), const Color(0xFF9370DB)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🎉 数据概览', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('🪙', '${stats['totalCoins']}', '金币'),
              _buildOverviewItem('🐾', '${stats['totalPets']}', '宠物'),
              _buildOverviewItem('📅', '${stats['signInDays']}', '签到'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
  
  Widget _buildStatCard(String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(item['icon'], color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(item['label'], style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Text(item['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildCoinCard() {
    final records = DataManager.getCoinRecords();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰 金币记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(child: Text('暂无记录', style: TextStyle(color: Colors.grey)))
          else
            ...records.take(10).map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(r['amount'] > 0 ? '➕' : '➖', style: TextStyle(color: r['amount'] > 0 ? Colors.green : Colors.red)),
                  const SizedBox(width: 8),
                  Text('${r['amount']}', style: TextStyle(color: r['amount'] > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r['desc'] ?? '')),
                  Text(r['time'], style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
