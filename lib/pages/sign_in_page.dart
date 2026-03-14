import 'package:flutter/material.dart';
import '../services/data_manager.dart';

// ==================== 签到页面 ====================
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final canSignIn = DataManager.canSignIn();
    final signInDays = DataManager.getSignInDays();
    final lastSignIn = DataManager.getLastSignIn();
    final coins = DataManager.getCoins();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('每日签到', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 金币显示
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber[400]!, Colors.amber[600]!]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 10),
                  Text('$coins', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // 签到卡片
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('连续签到', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$signInDays', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const Text(' 天', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (lastSignIn.isNotEmpty)
                    Text('上次签到: $lastSignIn', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canSignIn ? () async {
                        final result = await DataManager.signIn();
                        if (result['success'] && mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('签到成功! 🎉'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('+${result['coins']} 金币', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                                  if (result['bonus'] > 0) Text('+${result['bonus']} 连续签到奖励!', style: const TextStyle(color: Colors.red)),
                                  Text('连续 ${result['days']} 天', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                              actions: [TextButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('确定'))],
                            ),
                          );
                          setState(() {});
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSignIn ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(canSignIn ? '立即签到' : '明天再来', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 签到奖励说明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('签到奖励', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildRewardItem('基础奖励', '10 + 连续天数 × 5 金币'),
                  _buildRewardItem('连续7天', '额外 100 金币'),
                  _buildRewardItem('连续30天', '额外 500 金币'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardItem(String title, String desc) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text('• ', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(desc, style: TextStyle(color: Colors.grey[500])),
      ],
    ),
  );
}
