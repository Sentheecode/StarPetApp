import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 同城服务'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '🏠 寄养'),
                Tab(text: '🦮 上门喂养'),
              ],
              labelColor: Colors.white,
              indicatorColor: Colors.white,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBoardingTab(),
                  _buildFeedingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🏠 寄养店铺', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: '温馨宠物寄养屋',
          subtitle: '⭐ 4.8 · 距您 1.2km',
          price: '¥80/天',
          tags: ['猫狗寄养', '全天看护', '每日视频'],
        ),
        _buildServiceCard(
          title: '萌宠之家',
          subtitle: '⭐ 4.5 · 距您 2.5km',
          price: '¥60/天',
          tags: ['家庭式寄养', '专人照料'],
        ),
        _buildServiceCard(
          title: '宠物酒店',
          subtitle: '⭐ 4.9 · 距您 3.0km',
          price: '¥120/天',
          tags: ['高端寄养', '单独房间', '智能监控'],
        ),
      ],
    );
  }

  Widget _buildFeedingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🦮 上门喂养', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: '小王师傅',
          subtitle: '⭐ 5.0 · 已服务 200+ 次',
          price: '¥30/次',
          tags: ['喂粮换水', '陪玩互动', '清理卫生'],
        ),
        _buildServiceCard(
          title: '张阿姨宠物服务',
          subtitle: '⭐ 4.7 · 已服务 80+ 次',
          price: '¥25/次',
          tags: ['细心照料', '可遛狗'],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> tags,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: Text(title[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(price, style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 10)),
                backgroundColor: AppTheme.backgroundColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('立即预约'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
