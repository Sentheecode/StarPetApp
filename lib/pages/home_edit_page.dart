import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../services/home_data.dart';

// ==================== 家园编辑页面 ====================
class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});
  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  int _selectedTab = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('我的家园', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('${DataManager.getCoins()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _buildTab(0, '🏡 我的家园')),
                Expanded(child: _buildTab(1, '🛒 家具商店')),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildHomeView() : _buildShopView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(int index, String text) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF69B4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }
  
  Widget _buildHomeView() {
    final items = HomeData.placedItems;
    return items.isEmpty 
      ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('🏠', style: TextStyle(fontSize: 60)), SizedBox(height: 16), Text('暂无家具', style: TextStyle(fontSize: 18, color: Colors.grey)), Text('去商店购买一些家具吧', style: TextStyle(color: Colors.grey))]))
      : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: items.length,
          itemBuilder: (ctx, i) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(items[i]['icon'], style: const TextStyle(fontSize: 30)), const SizedBox(height: 4), Text(items[i]['name'], style: const TextStyle(fontSize: 10))])),
        );
  }
  
  Widget _buildShopView() {
    final categories = ['全部', '床', '家具', '玩具', '用品', '装饰'];
    String selectedCategory = '全部';
    return Column(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (ctx, i) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: selectedCategory == categories[i] ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text(categories[i], style: TextStyle(color: selectedCategory == categories[i] ? Colors.white : Colors.black))),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: HomeData.furniture.length,
            itemBuilder: (ctx, i) {
              final item = HomeData.furniture[i];
              return GestureDetector(
                onTap: () {
                  if (DataManager.getCoins() >= item['price']) {
                    DataManager.addCoins(-item['price']);
                    HomeData.addItem(item, 100, 100);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('购买成功: ${item['name']}')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金币不足')));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(item['icon'], style: const TextStyle(fontSize: 30)), const SizedBox(height: 4), Text(item['name'], style: const TextStyle(fontSize: 12)), Text('${item['price']}🪙', style: const TextStyle(fontSize: 10, color: Colors.amber))]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
