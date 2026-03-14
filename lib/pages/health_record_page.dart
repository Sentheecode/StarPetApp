import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../models/theme.dart';

// ==================== 健康记录页面 ====================
class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});
  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  @override
  Widget build(BuildContext context) {
    final records = DataManager.getHealthRecords();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('健康记录', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: records.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏥', style: TextStyle(fontSize: 60)),
                SizedBox(height: 16),
                Text('暂无健康记录', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('点击右上角添加健康记录', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (ctx, i) {
              final r = records[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_getEmoji(r['type']), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(r['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Text(r['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    if (r['detail'] != null && r['detail'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(r['detail'].toString(), style: TextStyle(color: Colors.grey[600])),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }
  
  String _getEmoji(String? type) {
    switch (type) {
      case 'weight': return '⚖️';
      case 'checkup': return '🏥';
      case 'medicine': return '💊';
      case 'illness': return '🤒';
      case 'beauty': return '✂️';
      default: return '📋';
    }
  }
  
  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    String selectedType = 'checkup';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加健康记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('类型', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip('⚖️', 'weight', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('🏥', 'checkup', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('💊', 'medicine', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('🤒', 'illness', selectedType, (t) => setDialogState(() => selectedType = t)),
                    _buildChip('✂️', 'beauty', selectedType, (t) => setDialogState(() => selectedType = t)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '详情',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  DataManager.addHealthRecord({
                    'type': selectedType,
                    'title': titleController.text,
                    'detail': detailController.text,
                    'date': DateTime.now().toString().substring(0, 10),
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChip(String emoji, String type, String selected, Function(String) onTap) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$emoji', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
