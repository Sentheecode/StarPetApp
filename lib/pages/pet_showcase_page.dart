import 'package:flutter/material.dart';
import '../widgets/corgi_pet.dart';

// ==================== 宠物展示页面 ====================
class PetShowcasePage extends StatefulWidget {
  const PetShowcasePage({super.key});
  @override
  State<PetShowcasePage> createState() => _PetShowcasePageState();
}

class _PetShowcasePageState extends State<PetShowcasePage> {
  bool _isWalking = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('我的柯基', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 动画展示
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const RadialGradient(colors: [Color(0xFFFFE4B5), Color(0xFFFFD700)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10)],
              ),
              child: Center(
                child: CorgiPet(
                  size: 160,
                  isWalking: _isWalking,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // 控制按钮
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text('动作控制', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('待机', Icons.pause, !_isWalking, () => setState(() => _isWalking = false)),
                      _buildButton('走路', Icons.directions_walk, _isWalking, () => setState(() => _isWalking = true)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('🐕 柯基动画测试', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
