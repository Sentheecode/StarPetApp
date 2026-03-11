import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/device/device_screen.dart';
import 'screens/service/service_screen.dart';
import 'screens/social/social_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'config/theme.dart';

class StarPetApp extends StatelessWidget {
  const StarPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星宠',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServiceScreen(),
    SocialScreen(),
    DeviceScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '家园'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: '服务'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: '社交'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: '设备'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
