import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../models/theme.dart';

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
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showPostDialog(context),
          ),
        ],
      ),
      body: posts.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🐾', style: TextStyle(fontSize: 60)),
                SizedBox(height: 16),
                Text('暂无动态', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('点击右上角发布第一条动态', style: TextStyle(color: Colors.grey)),
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
                            gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('🐱', style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('用户${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(post['time'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post['content'] ?? '', style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('❤️ ${post['likes'] ?? 0}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Text('💬 评论', style: TextStyle(color: Colors.grey)),
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
        title: const Text('发布动态'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '分享你和宠物的故事...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }
}
