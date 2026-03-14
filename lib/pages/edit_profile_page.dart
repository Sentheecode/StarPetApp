import 'package:flutter/material.dart';
import '../services/data_manager.dart';

// ==================== 编辑资料页面 ====================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nicknameController;
  Set<int> selectedRoles = {};
  
  final List<Map<String, String>> roles = [
    {'id': '1', 'name': '宠物主人', 'icon': '🐾', 'desc': '养宠物的主人'},
    {'id': '2', 'name': '上门喂养', 'icon': '🏠', 'desc': '提供上门服务'},
    {'id': '3', 'name': '云养宠', 'icon': '☁️', 'desc': '远程吸宠'},
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: DataManager.getNickname());
    final currentRoles = DataManager.getRoles();
    for (var role in roles) {
      if (currentRoles.contains(role['name'])) {
        selectedRoles.add(int.parse(role['id']!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('编辑资料', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              DataManager.setUserData('nickname', _nicknameController.text.isEmpty ? '点击编辑昵称' : _nicknameController.text);
              final selectedNames = roles.where((r) => selectedRoles.contains(int.parse(r['id']!))).map((r) => r['name']!).toList();
              DataManager.setUserData('roles', selectedNames);
              try {
                final success = await DataManager.saveAndGetResult();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? '✅ 保存成功' : '❌ 保存失败'), backgroundColor: success ? Colors.green : Colors.red));
                  if (success) Future.delayed(const Duration(milliseconds: 500), () => Navigator.pop(context, true));
                }
              } catch(e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 保存失败: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('保存', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('昵称', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              hintText: '请输入昵称',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          const Text('选择角色（可多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...roles.map((role) {
            final id = int.parse(role['id']!);
            final isSelected = selectedRoles.contains(id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) selectedRoles.remove(id);
                  else selectedRoles.add(id);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(role['icon']!, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role['name']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                          Text(role['desc']!, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white70 : Colors.grey[600])),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
