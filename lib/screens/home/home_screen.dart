import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/pet_provider.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载模拟数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadDemoData();
      context.read<PetProvider>().loadDemoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 家园'),
        actions: [
          Consumer<HomeProvider>(
            builder: (context, home, _) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('Lv.${home.level}'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 宠物状态栏
          _buildPetStatusBar(),
          // 家园场景
          Expanded(child: _buildHomeScene()),
        ],
      ),
    );
  }

  Widget _buildPetStatusBar() {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        if (petProvider.pets.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.cardColor,
          child: Row(
            children: [
              // 当前选中的宠物
              if (petProvider.selectedPet != null) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    petProvider.selectedPet!.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petProvider.selectedPet!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${petProvider.selectedPet!.species} · ${petProvider.selectedPet!.breed}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              // 宠物列表
              PopupMenuButton(
                icon: const Icon(Icons.pets, color: AppTheme.primaryColor),
                itemBuilder: (context) => petProvider.pets.map((pet) {
                  return PopupMenuItem(
                    value: pet,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.secondaryColor,
                          child: Text(pet.name[0]),
                        ),
                        const SizedBox(width: 8),
                        Text(pet.name),
                      ],
                    ),
                  );
                }).toList(),
                onSelected: (pet) => petProvider.selectPet(pet),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeScene() {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade100,
                Colors.green.shade100,
              ],
            ),
          ),
          child: Stack(
            children: [
              // 地面
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 150,
                child: Container(
                  color: Colors.brown.shade300,
                  child: const Center(
                    child: Text('🏡 家园场景 - 装修中...', 
                      style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              // 家具
              ...home.placedFurniture.entries.map((entry) {
                final furniture = home.ownedFurniture.firstWhere(
                  (f) => f.id == entry.key,
                  orElse: () => home.furnitures.first,
                );
                return Positioned(
                  left: entry.value.dx,
                  bottom: entry.value.dy + 150,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(furniture.name),
                  ),
                );
              }),
              // 添加家具按钮
              Positioned(
                right: 16,
                bottom: 170,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppTheme.accentColor,
                  onPressed: () => _showFurnitureShop(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFurnitureShop(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<HomeProvider>(
        builder: (context, home, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏪 家具商店', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: home.furnitures.length,
                    itemBuilder: (context, index) {
                      final furniture = home.furnitures[index];
                      return ListTile(
                        leading: Icon(
                          furniture.isOwned ? Icons.check_circle : Icons.shopping_cart,
                          color: furniture.isOwned ? AppTheme.successColor : AppTheme.primaryColor,
                        ),
                        title: Text(furniture.name),
                        subtitle: Text('${furniture.category} · ¥${furniture.price}'),
                        trailing: furniture.isOwned
                            ? const Text('已拥有')
                            : ElevatedButton(
                                onPressed: () {
                                  // TODO: 购买家具
                                },
                                child: const Text('购买'),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
