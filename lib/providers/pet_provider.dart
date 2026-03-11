import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetProvider extends ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _selectedPet;

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void removePet(String id) {
    _pets.removeWhere((p) => p.id == id);
    if (_selectedPet?.id == id) {
      _selectedPet = null;
    }
    notifyListeners();
  }

  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      notifyListeners();
    }
  }

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  // 模拟数据
  void loadDemoData() {
    _pets = [
      Pet(
        id: '1',
        name: '咪咪',
        species: '猫',
        breed: '英短',
        age: 24,
        gender: '母',
        createdAt: DateTime.now(),
      ),
      Pet(
        id: '2',
        name: '旺财',
        species: '狗',
        breed: '柯基',
        age: 12,
        gender: '公',
        createdAt: DateTime.now(),
      ),
    ];
    _selectedPet = _pets.first;
    notifyListeners();
  }
}
