import 'package:flutter/material.dart';
import '../models/furniture.dart';

class HomeProvider extends ChangeNotifier {
  // 家园等级
  int _level = 1;
  int _exp = 0;
  
  List<Furniture> get furnitures => _furnitures;
  List<Furniture> _furnitures = [];
  
  // 放置的家具位置
  Map<String, Offset> _placedFurniture = {};

  int get level => _level;
  int get exp => _exp;
  List<Furniture> get ownedFurniture => _furnitures.where((f) => f.isOwned).toList();
  Map<String, Offset> get placedFurniture => _placedFurniture;

  void addExp(int amount) {
    _exp += amount;
    while (_exp >= level * 100) {
      _exp -= level * 100;
      _level++;
    }
    notifyListeners();
  }

  void placeFurniture(String furnitureId, Offset position) {
    _placedFurniture[furnitureId] = position;
    notifyListeners();
  }

  void removeFurniture(String furnitureId) {
    _placedFurniture.remove(furnitureId);
    notifyListeners();
  }

  // 模拟数据
  void loadDemoData() {
    _furnitures = [
      Furniture(id: '1', name: '木质地板', category: '地板', price: 100, isOwned: true),
      Furniture(id: '2', name: '简约床', category: '家具', price: 200, isOwned: true),
      Furniture(id: '3', name: '猫爬架', category: '家具', price: 150, isOwned: true),
      Furniture(id: '4', name: '盆栽', category: '装饰', price: 50, isOwned: true),
      Furniture(id: '5', name: '墙纸', category: '墙面', price: 80, isOwned: false),
      Furniture(id: '6', name: '电视', category: '家具', price: 300, isOwned: false),
    ];
    _placedFurniture = {
      '1': const Offset(0, 300),
      '2': const Offset(100, 200),
      '3': const Offset(200, 250),
    };
    notifyListeners();
  }
}
