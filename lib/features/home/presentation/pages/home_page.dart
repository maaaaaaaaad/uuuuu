import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/favorite/presentation/pages/favorites_page.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/location/presentation/providers/location_permission_alert_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';
import 'package:jellomark/features/location/presentation/widgets/location_permission_alert_dialog.dart';
import 'package:jellomark/features/member/presentation/pages/profile_page.dart';
import 'package:jellomark/features/nearby_shops/presentation/pages/nearby_shops_map_page.dart';
import 'package:jellomark/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/current_reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/confirmed_reservation_toast.dart';
import 'package:jellomark/features/reservation/presentation/widgets/current_reservation_bar.dart';
import 'package:jellomark/features/search/presentation/pages/search_page.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/features/notification/presentation/providers/notification_provider.dart';
import 'package:jellomark/shared/widgets/glass_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  static const _dismissedToastKeyPrefix = 'dismissed_reservation_';

  int _currentIndex = 0;
  Set<String> _dismissedToastIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFcm();
      _checkLocationPermission();
      _loadCurrentReservations();
      _loadDismissedToastIds();
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

  Future<void> _loadDismissedToastIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_dismissedToastKeyPrefix));
    setState(() {
      _dismissedToastIds = keys.map((k) => k.substring(_dismissedToastKeyPrefix.length)).toSet();
    });
  }

  Future<void> _dismissToast(String reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_dismissedToastKeyPrefix$reservationId', true);
    setState(() {
      _dismissedToastIds = {..._dismissedToastIds, reservationId};
    });
  }

  void _navigateToReservationDetail(String reservationId) {
    ref.read(myReservationsNotifierProvider.notifier).loadReservations();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservationId: reservationId),
      ),
    );
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
        return const NearbyShopsMapPage(key: ValueKey(2));
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
    final reservationState = ref.watch(currentReservationNotifierProvider);
    final todayReservation = reservationState.todayReservation;
    final upcomingReservation = reservationState.upcomingReservation;

    final showToast = upcomingReservation != null &&
        !_dismissedToastIds.contains(upcomingReservation.id);

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildTab(_currentIndex),
            ),
            if (showToast)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: ConfirmedReservationToast(
                  reservation: upcomingReservation,
                  onTap: () => _navigateToReservationDetail(upcomingReservation.id),
                  onDismiss: () => _dismissToast(upcomingReservation.id),
                ),
              ),
            if (todayReservation != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 78,
                  ),
                  child: CurrentReservationBar(
                    reservation: todayReservation,
                    onTap: () => _navigateToReservationDetail(todayReservation.id),
                  ),
                ),
              ),
          ],
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
