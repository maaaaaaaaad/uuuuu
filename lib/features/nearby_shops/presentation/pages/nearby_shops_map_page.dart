import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/image_thumbnail_grid.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/nearby_shops/presentation/providers/nearby_shops_map_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class NearbyShopsMapPage extends ConsumerStatefulWidget {
  const NearbyShopsMapPage({super.key});

  @override
  ConsumerState<NearbyShopsMapPage> createState() => _NearbyShopsMapPageState();
}

class _NearbyShopsMapPageState extends ConsumerState<NearbyShopsMapPage> {
  NaverMapController? _controller;
  final Set<String> _activeMarkerIds = {};
  double? _userLat;
  double? _userLng;

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final state = ref.watch(nearbyShopsMapProvider);

    ref.listen<NearbyShopsMapState>(nearbyShopsMapProvider, (previous, next) {
      if (_controller != null && _userLat != null && _userLng != null) {
        if (previous?.shops != next.shops ||
            previous?.favoriteShopIds != next.favoriteShopIds) {
          _updateMarkers(next, _userLat!, _userLng!);
        }
      }
    });

    return Scaffold(
      body: locationAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState('위치를 가져올 수 없습니다'),
        data: (location) {
          if (location == null) {
            return _buildErrorState('위치 권한이 필요합니다');
          }
          return _buildMapWithBottomSheet(location, state);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: SemanticColors.indicator.loading),
          const SizedBox(height: 16),
          Text(
            '현재 위치를 확인하고 있습니다...',
            style: TextStyle(color: SemanticColors.text.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: SemanticColors.icon.disabled,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: SemanticColors.text.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWithBottomSheet(dynamic location, NearbyShopsMapState state) {
    return Stack(
      children: [
        _buildMap(location.latitude, location.longitude, state),
        if (state.isLoading)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: SemanticColors.background.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SemanticColors.indicator.loading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '주변 샵 검색 중...',
                      style: TextStyle(
                        color: SemanticColors.text.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (state.selectedShop != null)
          _buildBottomSheet(state.selectedShop!),
      ],
    );
  }

  Widget _buildMap(double userLat, double userLng, NearbyShopsMapState state) {
    _userLat = userLat;
    _userLng = userLng;

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(userLat, userLng),
          zoom: 14,
        ),
        minZoom: 10.0,
        maxZoom: 18.0,
        scrollGesturesEnable: true,
        zoomGesturesEnable: true,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        scaleBarEnable: false,
        locationButtonEnable: true,
        logoClickEnable: false,
      ),
      onMapReady: (controller) {
        _controller = controller;
        _updateMarkers(state, userLat, userLng);
      },
      onMapTapped: (point, latLng) {
        ref.read(nearbyShopsMapProvider.notifier).clearSelection();
      },
    );
  }

  Future<void> _updateMarkers(
    NearbyShopsMapState state,
    double userLat,
    double userLng,
  ) async {
    final controller = _controller;
    if (controller == null) return;

    for (final id in _activeMarkerIds) {
      try {
        await controller.deleteOverlay(
          NOverlayInfo(type: NOverlayType.marker, id: id),
        );
      } catch (_) {}
    }
    _activeMarkerIds.clear();

    final userMarker = NMarker(
      id: 'user_marker',
      position: NLatLng(userLat, userLng),
      caption: NOverlayCaption(
        text: '내 위치',
        textSize: 11,
        color: Colors.blue,
      ),
      iconTintColor: Colors.blue,
    );
    await controller.addOverlay(userMarker);
    _activeMarkerIds.add('user_marker');

    for (final shop in state.shops) {
      if (shop.latitude == null || shop.longitude == null) continue;

      final isFavorite = state.favoriteShopIds.contains(shop.id);
      final markerId = 'shop_${shop.id}';
      final displayName = shop.name.length > 10
          ? '${shop.name.substring(0, 10)}...'
          : shop.name;

      final marker = NMarker(
        id: markerId,
        position: NLatLng(shop.latitude!, shop.longitude!),
        caption: NOverlayCaption(
          text: isFavorite ? '$displayName ♥' : displayName,
          textSize: 11,
          color: Colors.black87,
          haloColor: Colors.white,
          minZoom: 12,
        ),
      );

      marker.setOnTapListener((marker) {
        ref.read(nearbyShopsMapProvider.notifier).selectShop(shop);
      });

      await controller.addOverlay(marker);
      _activeMarkerIds.add(markerId);
    }
  }

  Widget _buildBottomSheet(BeautyShop shop) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            ref.read(nearbyShopsMapProvider.notifier).clearSelection();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop.images.isNotEmpty) ...[
                        ImageThumbnailGrid(
                          imageUrls: shop.images.take(4).toList(),
                          imageSize: 70,
                          crossAxisCount: 4,
                        ),
                        const SizedBox(height: 12),
                      ],
                      ShopInfoHeader(
                        name: shop.name,
                        rating: shop.rating,
                        reviewCount: shop.reviewCount,
                        distance: shop.formattedDistance,
                        address: shop.address,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToShopDetail(shop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SemanticColors.button.primary,
                            foregroundColor: SemanticColors.button.primaryText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '상세보기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: SemanticColors.border.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _navigateToShopDetail(BeautyShop shop) {
    ref.read(nearbyShopsMapProvider.notifier).clearSelection();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShopDetailScreen(shop: shop),
      ),
    );
  }
}
