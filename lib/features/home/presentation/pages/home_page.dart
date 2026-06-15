import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/helpers/auth_action_guard.dart';
import 'package:jellomark/features/favorite/presentation/pages/favorites_page.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/location/presentation/providers/location_permission_alert_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/features/location/presentation/widgets/location_permission_alert_dialog.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/nearby_shops/presentation/pages/nearby_shops_map_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/current_reservation_provider.dart';
import 'package:jellomark/features/search/presentation/pages/search_page.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/features/notification/presentation/providers/notification_provider.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFcm();
      _checkLocationPermission();
      _loadCurrentReservations();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCurrentReservations();
    }
  }

  void _initializeFcm() {
    ref.read(notificationInitProvider);
  }

  void _loadCurrentReservations() {
    ref.read(currentReservationNotifierProvider.notifier).load();
  }

  Future<void> _checkLocationPermission() async {
    final notifier = ref.read(locationPermissionAlertProvider.notifier);
    final shouldShow = await notifier.shouldShowAlert();

    if (shouldShow && mounted) {
      notifier.markAsShown();
      if (mounted) {
        await LocationPermissionAlertDialog.show(
          context: context,
          onAgree: _handleAgreePermission,
          onCancel: () {},
        );
      }
    }
  }

  Future<void> _handleAgreePermission() async {
    final notifier = ref.read(locationSettingNotifierProvider.notifier);
    await notifier.requestPermissionAndEnable();
  }

  void _switchToSearchTab() {
    setState(() => _currentIndex = 1);
  }

  Future<void> _handleTabTap(int index) async {
    final requiresLogin = index == 3 || index == 4;
    if (requiresLogin) {
      final description = index == 3
          ? '즐겨찾기를 보려면 로그인이 필요해요.'
          : '마이페이지를 보려면 로그인이 필요해요.';
      final loggedIn = await ensureLoggedIn(
        context,
        ref,
        description: description,
      );
      if (!loggedIn || !mounted) return;
    }
    setState(() => _currentIndex = index);
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
      icon: Icons.near_me_outlined,
      selectedIcon: Icons.near_me,
      label: '주변',
      isFloating: true,
    ),
    BottomNavItem(
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      label: '즐겨찾기',
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
        return NearbyShopsMapPage(
          key: const ValueKey(2),
          onSwitchToHomeTab: () => setState(() => _currentIndex = 0),
        );
      case 3:
        return const FavoritesPage(key: ValueKey(3));
      case 4:
        return const ProfilePage(key: ValueKey(4));
      default:
        return HomeTab(key: const ValueKey(0), onSearchTap: _switchToSearchTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.softWhiteGradient,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildTab(_currentIndex),
          ),
        ),
        bottomNavigationBar: GlassBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleTabTap,
          items: _navItems,
        ),
      ),
    );
  }
}
