import 'package:flutter/material.dart';
import 'package:plantly_app/pages/garden_page.dart';
import '../widgets/bottom_appbar/plantly_bottom_navigation.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    GardenPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: PlantlyBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex == index) return;
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
