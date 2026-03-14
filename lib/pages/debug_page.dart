import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../services/home_data.dart';

// ==================== 调试页面 ====================
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  Map<String, dynamic> _rawDbData = {};
  
  @override
  void initState() {
    super.initState();
    _loadRawData();
  }
  
  Future<void> _loadRawData() async {
    final data = await DataManager.getRawUserData();
    if (mounted) {
      setState(() => _rawDbData = data);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final nickname = DataManager.getNickname();
    final coins = DataManager.getCoins();
    final theme = DataManager.getCurrentTheme();
    final signInDays = DataManager.getSignInDays();
    final lastSignIn = DataManager.getLastSignIn();
    final pets = DataManager.getPets();
    final homeItems = HomeData.placedItems;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('调试信息', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('数据库原始数据', [
              {'key': 'coins', 'value': '${_rawDbData['coins']}'},
              {'key': 'lastSignIn', 'value': '${_rawDbData['lastSignIn']}'},
              {'key': 'signInDays', 'value': '${_rawDbData['signInDays']}'},
              {'key': 'theme', 'value': '${_rawDbData['theme']}'},
            ]),
            ElevatedButton(onPressed: _loadRawData, child: const Text('刷新数据库数据')),
            const SizedBox(height: 16),
            _buildSection('内存数据', [
              {'key': '昵称', 'value': nickname},
              {'key': '主题', 'value': '$theme'},
              {'key': '金币', 'value': '$coins'},
            ]),
            _buildSection('签到数据', [
              {'key': '连续天数', 'value': '$signInDays'},
              {'key': '上次签到', 'value': lastSignIn.isEmpty ? '未签到' : lastSignIn},
            ]),
            _buildSection('宠物数据', [
              {'key': '宠物数量', 'value': '${pets.length}'},
              ...pets.asMap().entries.map((e) => {'key': '宠物${e.key+1}', 'value': '${e.value['name']} (${e.value['type']})'}),
            ]),
            _buildSection('家园数据', [
              {'key': '家具数量', 'value': '${homeItems.length}'},
              ...homeItems.asMap().entries.map((e) => {'key': '家具${e.key+1}', 'value': '${e.value['name']}'}),
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Map<String, String>> items) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('${item['key']}: ', style: TextStyle(color: Colors.grey[600])),
              Expanded(child: Text(item['value'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
        )),
      ],
    ),
  );
}
