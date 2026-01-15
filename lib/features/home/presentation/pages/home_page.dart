import 'package:flutter/material.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/search/presentation/pages/search_page.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _switchToSearchTab() {
    setState(() => _currentIndex = 1);
  }

  static const _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '홈',
    ),
    BottomNavItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: '검색',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: '마이',
    ),
  ];

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return HomeTab(key: const ValueKey(0), onSearchTap: _switchToSearchTab);
      case 1:
        return const SearchPage(key: ValueKey(1));
      case 2:
        return const ProfilePage(key: ValueKey(2));
      default:
        return HomeTab(key: const ValueKey(0), onSearchTap: _switchToSearchTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _buildTab(_currentIndex),
        ),
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}
