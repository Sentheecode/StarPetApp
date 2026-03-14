import 'package:flutter/material.dart';
import '../services/data_manager.dart';

// ==================== 成就页面 ====================
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final achievements = DataManager.getAchievements();
    final unlocked = achievements.where((a) => a['unlocked'] == true).length;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('成就', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 进度条
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('成就进度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$unlocked / ${achievements.length}', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: unlocked / achievements.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          // 成就列表
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = ach['unlocked'] == true;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: isUnlocked ? Border.all(color: Colors.orange, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ach['icon'], style: TextStyle(fontSize: 32, color: isUnlocked ? null : Colors.grey)),
                      const SizedBox(height: 8),
                      Text(ach['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey)),
                      const SizedBox(height: 4),
                      Text(ach['desc'], style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
                      if (isUnlocked) ...[
                        const SizedBox(height: 4),
                        const Text('✅ 已完成', style: TextStyle(fontSize: 10, color: Colors.green)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
