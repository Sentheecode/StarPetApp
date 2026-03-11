import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 宠物社交'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类标签
          Container(
            height: 50,
            color: AppTheme.cardColor,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CategoryChip(icon: Icons.whatshot, label: '热门'),
                _CategoryChip(icon: Icons.near_me, label: '附近'),
                _CategoryChip(icon: Icons.favorite, label: '关注'),
                _CategoryChip(icon: Icons.category, label: '广场'),
              ],
            ),
          ),
          // 内容列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 10,
              itemBuilder: (context, index) => _buildPostCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final posts = [
      {'user': '咪咪妈', 'pet': '英短', 'content': '今天带咪咪去宠物店洗澡，太乖了！', 'likes': 234, 'comments': 45},
      {'user': '旺财爸', 'pet': '柯基', 'content': '小短腿又犯错了，把纸巾撕了一地🙄', 'likes': 189, 'comments': 23},
      {'user': '小橘同学', 'pet': '橘猫', 'content': '橘猫果然是胖的代名词...', 'likes': 567, 'comments': 89},
      {'user': '毛球妈', 'pet': '萨摩耶', 'content': '三傻之一的萨摩耶果然名不虚传', 'likes': 321, 'comments': 56},
    ];
    
    final Map<String, dynamic> post = posts[index % posts.length];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(post['user'][0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${post['pet']} · 2小时前', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(post['content']!),
          ),
          // 图片占位
          Container(
            height: 200,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.pets, size: 48, color: Colors.white),
            ),
          ),
          // 互动按钮
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _InteractionButton(icon: Icons.favorite_border, label: '${post['likes']}'),
                const SizedBox(width: 16),
                _InteractionButton(icon: Icons.chat_bubble_outline, label: '${post['comments']}'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InteractionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}
