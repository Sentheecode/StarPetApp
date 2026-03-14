import 'package:flutter/material.dart';

// ==================== 帮助与反馈页面 ====================
class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('帮助与反馈', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQ('如何添加宠物?', '进入"我的"页面，点击"我的宠物"，然后点击+按钮添加'),
          _buildFAQ('如何修改昵称?', '点击头像区域的昵称即可编辑'),
          _buildFAQ('什么是云养宠?', '远程关注其他用户的宠物'),
          _buildFAQ('数据会自动保存吗?', '是的，所有数据会自动保存到本地'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('反馈功能开发中...')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('提交反馈', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
