import 'package:flutter/material.dart';
import '../services/data_manager.dart';

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
    DataManager.addPost({
      'content': _contentController.text, 
      'time': DateTime.now().toString().substring(0, 16), 
      'likes': 0
    });
    Navigator.pop(context, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)), 
        title: const Text('发布博文', style: TextStyle(color: Colors.black)), 
        centerTitle: true, 
        actions: [TextButton(onPressed: _publishPost, child: const Text('发布', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)))]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), 
        child: TextField(
          controller: _contentController, 
          maxLines: null, 
          minLines: 10, 
          decoration: const InputDecoration(hintText: '分享你和宠物的故事...', border: InputBorder.none), 
          style: const TextStyle(fontSize: 16)
        )
      ),
    );
  }
}
