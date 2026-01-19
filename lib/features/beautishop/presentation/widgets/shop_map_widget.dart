import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:jellomark/features/location/domain/entities/route.dart'
    as domain;
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopMapWidget extends StatefulWidget {
  final double shopLatitude;
  final double shopLongitude;
  final String shopName;
  final double? userLatitude;
  final double? userLongitude;
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
    this.routeCoordinates,
    this.interactiveMode = true,
  });

  @override
  State<ShopMapWidget> createState() => _ShopMapWidgetState();
}

class _ShopMapWidgetState extends State<ShopMapWidget> {
  NaverMapController? _controller;
  final Set<String> _activeOverlayIds = {};
  bool _hasInitialCameraUpdate = false;

  @override
  void didUpdateWidget(covariant ShopMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final routeChanged = !_areRouteCoordinatesEqual(
      oldWidget.routeCoordinates,
      widget.routeCoordinates,
    );
    final userLocationChanged =
        oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude;

    if (routeChanged || userLocationChanged) {
      debugPrint(
        '[ShopMapWidget] Data changed - route: $routeChanged, userLocation: $userLocationChanged',
      );
      _updateOverlays(fitCamera: routeChanged && _hasNewRouteData(oldWidget));
    }
  }

  bool _hasNewRouteData(ShopMapWidget oldWidget) {
    final oldHadRoute =
        oldWidget.routeCoordinates != null &&
        oldWidget.routeCoordinates!.length >= 2;
    final newHasRoute =
        widget.routeCoordinates != null && widget.routeCoordinates!.length >= 2;
    return !oldHadRoute && newHasRoute;
  }

  bool _areRouteCoordinatesEqual(
    List<domain.LatLng>? a,
    List<domain.LatLng>? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return const DeepCollectionEquality().equals(a, b);
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ShopMapWidget.useTestMode) {
      return _buildTestPlaceholder();
    }
    return _buildNaverMap();
  }

  Widget _buildNaverMap() {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(widget.shopLatitude, widget.shopLongitude),
          zoom: 15,
        ),
        minZoom: ShopMapWidget.defaultMinZoom,
        maxZoom: ShopMapWidget.defaultMaxZoom,
        scrollGesturesEnable: widget.interactiveMode,
        zoomGesturesEnable: widget.interactiveMode,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        stopGesturesEnable: widget.interactiveMode,
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
              widget.shopName,
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

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    _updateOverlays(fitCamera: true);
  }

  Future<void> _updateOverlays({bool fitCamera = false}) async {
    final controller = _controller;
    if (controller == null) return;

    await _clearOverlays(controller);

    final boundsPoints = <NLatLng>[];

    final shopPosition = NLatLng(widget.shopLatitude, widget.shopLongitude);
    boundsPoints.add(shopPosition);

    final shopMarker = NMarker(
      id: 'shop_marker',
      position: shopPosition,
      caption: NOverlayCaption(text: widget.shopName),
    );
    await controller.addOverlay(shopMarker);
    _activeOverlayIds.add('shop_marker');

    if (widget.userLatitude != null && widget.userLongitude != null) {
      final userPosition = NLatLng(widget.userLatitude!, widget.userLongitude!);
      boundsPoints.add(userPosition);

      final userMarker = NMarker(
        id: 'user_marker',
        position: userPosition,
        caption: NOverlayCaption(
          text: '현재 위치',
          textSize: 12,
          color: Colors.blue,
        ),
        iconTintColor: Colors.blue,
      );
      await controller.addOverlay(userMarker);
      _activeOverlayIds.add('user_marker');
    }

    if (widget.routeCoordinates != null &&
        widget.routeCoordinates!.length >= 2) {
      debugPrint(
        '[ShopMapWidget] Drawing route with ${widget.routeCoordinates!.length} points',
      );

      final pathCoords = widget.routeCoordinates!
          .map((c) => NLatLng(c.latitude, c.longitude))
          .toList();

      final pathOverlay = NPathOverlay(
        id: 'route_path',
        coords: pathCoords,
        color: Colors.blue,
        width: 5,
      );
      await controller.addOverlay(pathOverlay);
      _activeOverlayIds.add('route_path');

      debugPrint('[ShopMapWidget] Route path overlay added');
    }

    if (fitCamera && boundsPoints.length >= 2) {
      final bounds = NLatLngBounds.from(boundsPoints);
      final cameraUpdate = NCameraUpdate.fitBounds(
        bounds,
        padding: const EdgeInsets.all(60),
      );
      await controller.updateCamera(cameraUpdate);
      _hasInitialCameraUpdate = true;
      debugPrint('[ShopMapWidget] Camera fitted to bounds');
    } else if (!_hasInitialCameraUpdate && boundsPoints.length == 1) {
      _hasInitialCameraUpdate = true;
    }
  }

  Future<void> _clearOverlays(NaverMapController controller) async {
    for (final id in _activeOverlayIds) {
      try {
        if (id == 'route_path') {
          await controller.deleteOverlay(
            NOverlayInfo(type: NOverlayType.pathOverlay, id: id),
          );
        } else {
          await controller.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: id),
          );
        }
      } catch (e) {
        debugPrint('[ShopMapWidget] Failed to delete overlay $id: $e');
      }
    }
    _activeOverlayIds.clear();
  }
}
