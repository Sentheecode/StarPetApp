import 'package:flutter/material.dart';

// ==================== 角色选择页面 ====================
class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  final List<Map<String, dynamic>> roles = [
    {'id': 1, 'name': '宠物主人', 'icon': '🐾', 'desc': '养宠物，装饰家园'},
    {'id': 2, 'name': '上门喂养/寄养', 'icon': '🏠', 'desc': '提供上门服务和寄养'},
    {'id': 3, 'name': '云养宠', 'icon': '☁️', 'desc': '远程吸宠，交友互动'},
  ];
  
  final Set<int> selectedRoles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('选择角色', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('请选择您的角色\n（可多选）', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  final isSelected = selectedRoles.contains(role['id']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) selectedRoles.remove(role['id']);
                        else selectedRoles.add(role['id']);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, 
                            height: 60, 
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.grey[100], 
                              borderRadius: BorderRadius.circular(16)
                            ), 
                            child: Center(child: Text(role['icon'], style: const TextStyle(fontSize: 30)))
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(role['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4), 
                                Text(role['desc'], style: TextStyle(fontSize: 13, color: Colors.grey[600]))
                              ]
                            )
                          ),
                          if (isSelected) Container(
                            width: 28, 
                            height: 28, 
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), 
                            child: const Icon(Icons.check, color: Colors.white, size: 18)
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRoles.isEmpty ? null : () { Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    foregroundColor: Colors.white, 
                    disabledBackgroundColor: Colors.grey[300], 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: const Text('下一步', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
