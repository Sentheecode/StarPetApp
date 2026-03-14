import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../models/theme.dart';

// ==================== 疫苗提醒页面 ====================
class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});
  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  @override
  Widget build(BuildContext context) {
    final vaccines = DataManager.getVaccines();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('疫苗提醒', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: vaccines.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💉', style: TextStyle(fontSize: 60)),
                SizedBox(height: 16),
                Text('暂无疫苗记录', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('点击右上角添加疫苗记录', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaccines.length,
            itemBuilder: (ctx, i) {
              final v = vaccines[i];
              final isOverdue = v['isOverdue'] == true;
              final isUpcoming = v['isUpcoming'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isOverdue ? Border.all(color: Colors.red, width: 2) : (isUpcoming ? Border.all(color: Colors.orange, width: 2) : null),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red.withValues(alpha: 0.1) : (isUpcoming ? Colors.orange.withValues(alpha: 0.1) : const Color(0xFF4CAF50).withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('💉', style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(v['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red : (isUpcoming ? Colors.orange : Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOverdue ? '已过期' : (isUpcoming ? '即将到期' : '已接种'),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
  
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加疫苗记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '疫苗名称',
                hintText: '如：狂犬疫苗',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: '接种日期',
                hintText: '如：2026-03-14',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                DataManager.addVaccine({
                  'name': nameController.text,
                  'date': dateController.text,
                });
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
