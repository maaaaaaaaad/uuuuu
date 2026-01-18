import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jellomark/features/location/domain/entities/route.dart' as domain;
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopMapWidget extends StatelessWidget {
  final double shopLatitude;
  final double shopLongitude;
  final String shopName;
  final double? userLatitude;
  final double? userLongitude;
  final double height;
  final List<domain.LatLng>? routeCoordinates;
  final bool interactiveMode;

  @visibleForTesting
  static bool useTestMode = false;

  static const double defaultMinZoom = 10.0;
  static const double defaultMaxZoom = 18.0;

  const ShopMapWidget({
    super.key,
    required this.shopLatitude,
    required this.shopLongitude,
    required this.shopName,
    this.userLatitude,
    this.userLongitude,
    this.height = 200,
    this.routeCoordinates,
    this.interactiveMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: useTestMode ? _buildTestPlaceholder() : _buildNaverMap(),
      ),
    );
  }

  Widget _buildNaverMap() {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(shopLatitude, shopLongitude),
          zoom: 15,
        ),
        minZoom: defaultMinZoom,
        maxZoom: defaultMaxZoom,
        scrollGesturesEnable: interactiveMode,
        zoomGesturesEnable: interactiveMode,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        stopGesturesEnable: interactiveMode,
        liteModeEnable: false,
        scaleBarEnable: false,
        locationButtonEnable: false,
        logoClickEnable: false,
      ),
      onMapReady: _onMapReady,
    );
  }

  Widget _buildTestPlaceholder() {
    return Container(
      color: SemanticColors.background.placeholder,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: SemanticColors.icon.secondary,
            ),
            const SizedBox(height: 8),
            Text(
              shopName,
              style: TextStyle(
                color: SemanticColors.text.secondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapReady(NaverMapController controller) async {
    final shopMarker = NMarker(
      id: 'shop_marker',
      position: NLatLng(shopLatitude, shopLongitude),
      caption: NOverlayCaption(text: shopName),
    );
    controller.addOverlay(shopMarker);

    if (userLatitude != null && userLongitude != null) {
      final userMarker = NMarker(
        id: 'user_marker',
        position: NLatLng(userLatitude!, userLongitude!),
        caption: NOverlayCaption(
          text: '현재 위치',
          textSize: 12,
          color: Colors.blue,
        ),
        iconTintColor: Colors.blue,
      );
      controller.addOverlay(userMarker);

      final bounds = NLatLngBounds.from([
        NLatLng(shopLatitude, shopLongitude),
        NLatLng(userLatitude!, userLongitude!),
      ]);
      final cameraUpdate = NCameraUpdate.fitBounds(
        bounds,
        padding: const EdgeInsets.all(50),
      );
      await controller.updateCamera(cameraUpdate);
    }

    if (routeCoordinates != null && routeCoordinates!.length >= 2) {
      debugPrint('[ShopMapWidget] Drawing route path with ${routeCoordinates!.length} coordinates');
      final pathCoords = routeCoordinates!
          .map((c) => NLatLng(c.latitude, c.longitude))
          .toList();
      debugPrint('[ShopMapWidget] First coord: ${pathCoords.first}, Last coord: ${pathCoords.last}');
      final pathOverlay = NPathOverlay(
        id: 'route_path',
        coords: pathCoords,
        color: Colors.blue,
        width: 5,
      );
      controller.addOverlay(pathOverlay);
      debugPrint('[ShopMapWidget] Route path overlay added');
    } else {
      debugPrint('[ShopMapWidget] No route to draw: coords=${routeCoordinates?.length ?? 0}');
    }
  }
}
