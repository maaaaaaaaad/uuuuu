import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/location/presentation/providers/location_permission_alert_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/features/location/presentation/widgets/location_permission_alert_dialog.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/search/presentation/pages/search_page.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
    });
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
    debugPrint('[HomePage] _handleAgreePermission called');
    final notifier = ref.read(locationSettingNotifierProvider.notifier);
    debugPrint('[HomePage] Calling requestPermissionAndEnable...');
    final result = await notifier.requestPermissionAndEnable();
    debugPrint('[HomePage] requestPermissionAndEnable result: $result');

    if (!mounted) return;

    if (result == LocationSettingToggleResult.serviceDisabled) {
      debugPrint('[HomePage] Location services disabled, showing location settings dialog...');
      _showLocationServiceDisabledDialog(notifier);
    } else if (result == LocationSettingToggleResult.deniedForever) {
      debugPrint('[HomePage] Permission denied forever, showing settings dialog...');
      _showSettingsRequiredDialog(notifier);
    }
  }

  void _showLocationServiceDisabledDialog(LocationSettingNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('위치 서비스 비활성화'),
        content: const Text(
          '기기의 위치 서비스가 꺼져 있습니다.\n\n'
          '위치 기반 서비스를 사용하려면 설정에서 위치 서비스를 켜주세요.\n\n'
          '설정 > 개인 정보 보호 및 보안 > 위치 서비스',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await notifier.openLocationSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _showSettingsRequiredDialog(LocationSettingNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('위치 권한 설정 필요'),
        content: const Text(
          '이전에 위치 권한을 거부하셨습니다.\n\n'
          '위치 기반 서비스를 사용하려면 iOS 설정에서 직접 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await notifier.openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

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
