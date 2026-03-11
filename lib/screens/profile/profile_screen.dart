import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 个人中心'),
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('宠物主人', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('养了 ${petProvider.pets.length} 只宠物',
                              style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 我的宠物
              _buildSectionTitle('🐾 我的宠物'),
              const SizedBox(height: 8),
              ...petProvider.pets.map((pet) => _buildPetCard(context, pet)),
              
              // 添加宠物按钮
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor,
                    child: const Icon(Icons.add, color: AppTheme.primaryColor),
                  ),
                  title: const Text('添加新宠物'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAddPetDialog(context),
                ),
              ),
              const SizedBox(height: 20),
              
              // 其他功能
              _buildSectionTitle('⚙️ 更多功能'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _buildMenuItem(Icons.favorite_outline, '我的收藏'),
                    _buildMenuItem(Icons.history, '浏览历史'),
                    _buildMenuItem(Icons.receipt_long, '订单记录'),
                    _buildMenuItem(Icons.wallet, '我的钱包'),
                    _buildMenuItem(Icons.help_outline, '帮助与反馈'),
                    _buildMenuItem(Icons.info_outline, '关于我们'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPetCard(BuildContext context, pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            pet.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(pet.name),
        subtitle: Text('${pet.species} · ${pet.breed} · ${pet.age}个月'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400),
              onPressed: () {
                context.read<PetProvider>().removePet(pet.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  void _showAddPetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加宠物'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: '名字')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: '品种')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: '年龄(月)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
