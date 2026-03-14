import 'package:flutter/material.dart';

// ==================== 消息通知页面 ====================
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('消息通知', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitch('接收推送通知', '开启后接收新消息提醒', _pushEnabled, (v) => setState(() => _pushEnabled = v)),
          _buildSwitch('声音', '消息提示音', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
          _buildSwitch('震动', '消息震动提醒', _vibrateEnabled, (v) => setState(() => _vibrateEnabled = v)),
        ],
      ),
    );
  }
  
  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
