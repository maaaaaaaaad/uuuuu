import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/presentation/pages/review_list_page.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/full_screen_image_viewer.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/image_thumbnail_grid.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_map_widget.dart';
import 'package:jellomark/features/location/domain/entities/route.dart'
    as domain;
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';

class ShopDetailScreen extends ConsumerWidget {
  final BeautyShop shop;

  static const double _sheetInitialSize = 0.55;
  static const double _sheetMinSize = 0.25;
  static const double _sheetMaxSize = 0.95;
  static const double _sheetBorderRadius = 24.0;
  static const double _contentPadding = 16.0;
  static const double _bottomButtonHeight = 56.0;

  const ShopDetailScreen({super.key, required this.shop});

  ShopDetail _buildShopDetail() {
    String phoneNumber = '';
    String? description;
    Map<String, String>? operatingHoursMap;
    List<String> images = [];

    if (shop is BeautyShopModel) {
      final model = shop as BeautyShopModel;
      phoneNumber = model.phoneNumber;
      description = model.description;
      operatingHoursMap = model.operatingTimeMap;
      if (model.imageUrl != null) {
        images = [model.imageUrl!];
      }
    } else {
      if (shop.imageUrl != null) {
        images = [shop.imageUrl!];
      }
    }

    return ShopDetail(
      id: shop.id,
      name: shop.name,
      address: shop.address,
      description: description ?? '',
      phoneNumber: phoneNumber,
      images: images,
      operatingHoursMap: operatingHoursMap,
      rating: shop.rating,
      reviewCount: shop.reviewCount,
      distance: shop.distance,
      tags: shop.tags,
      discountRate: shop.discountRate,
      isNew: shop.isNew,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopDetail = _buildShopDetail();
    final treatmentsAsync = ref.watch(shopTreatmentsProvider(shop.id));
    final userLocationAsync = ref.watch(currentLocationProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final mapBottomPadding = screenHeight * _sheetMinSize;

    final userLocation = userLocationAsync.valueOrNull;
    AsyncValue<domain.Route?>? routeAsync;
    if (userLocation != null &&
        shop.latitude != null &&
        shop.longitude != null) {
      routeAsync = ref.watch(
        routeProvider(
          RouteParams(
            startLat: userLocation.latitude,
            startLng: userLocation.longitude,
            endLat: shop.latitude!,
            endLng: shop.longitude!,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildMapLayer(userLocationAsync, routeAsync, mapBottomPadding),
          _buildBackButton(context),
          _buildShopInfoSheet(context, shopDetail, treatmentsAsync, routeAsync),
          _buildBottomReservationButton(context),
        ],
      ),
    );
  }

  Widget _buildMapLayer(
    AsyncValue<dynamic> userLocationAsync,
    AsyncValue<domain.Route?>? routeAsync,
    double mapBottomPadding,
  ) {
    if (shop.latitude == null || shop.longitude == null) {
      return Positioned.fill(
        child: Container(
          color: SemanticColors.background.cardAccent,
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 48,
              color: SemanticColors.icon.disabled,
            ),
          ),
        ),
      );
    }

    final userLocation = userLocationAsync.valueOrNull;
    final route = routeAsync?.valueOrNull;

    return Positioned.fill(
      child: ShopMapWidget(
        shopLatitude: shop.latitude!,
        shopLongitude: shop.longitude!,
        shopName: shop.name,
        userLatitude: userLocation?.latitude,
        userLongitude: userLocation?.longitude,
        routeCoordinates: route?.coordinates,
        bottomPadding: mapBottomPadding,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 8,
      left: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SemanticColors.background.appBar,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SemanticColors.border.glass),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfoSheet(
    BuildContext context,
    ShopDetail shopDetail,
    AsyncValue<List<ServiceMenu>> treatmentsAsync,
    AsyncValue<domain.Route?>? routeAsync,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetInitialSize,
      minChildSize: _sheetMinSize,
      maxChildSize: _sheetMaxSize,
      snap: true,
      snapSizes: const [_sheetMinSize, _sheetInitialSize, _sheetMaxSize],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_sheetBorderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: SemanticColors.overlay.shadowMedium,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _buildSheetContent(
            context,
            scrollController,
            shopDetail,
            treatmentsAsync,
            routeAsync,
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    ScrollController scrollController,
    ShopDetail shopDetail,
    AsyncValue<List<ServiceMenu>> treatmentsAsync,
    AsyncValue<domain.Route?>? routeAsync,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shopDetail.images.isNotEmpty) ...[
                ImageThumbnailGrid(
                  imageUrls: shopDetail.images,
                  imageSize: 60,
                  onImageTap: (index) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          images: shopDetail.images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              GlassCard(
                padding: EdgeInsets.zero,
                child: ShopInfoHeader(
                  name: shopDetail.name,
                  rating: shopDetail.rating,
                  reviewCount: shopDetail.reviewCount,
                  distance: _getDisplayDistance(
                    routeAsync,
                    shopDetail.distance,
                  ),
                  address: shopDetail.address,
                  onReviewTap: () => _navigateToReviewList(context),
                ),
              ),
              if (shopDetail.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: ShopDescription(description: shopDetail.description),
                ),
              ],
              if (shopDetail.operatingHoursMap != null &&
                  shopDetail.operatingHoursMap!.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: OperatingHoursCard(
                    operatingHours: shopDetail.operatingHoursMap!,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildServiceMenuSection(treatmentsAsync),
              SizedBox(height: _bottomButtonHeight + bottomPadding + 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  Widget _buildServiceMenuSection(
    AsyncValue<List<ServiceMenu>> treatmentsAsync,
  ) {
    return treatmentsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시술 메뉴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: SemanticColors.indicator.loading,
              ),
            ),
          ),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시술 메뉴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '시술 정보를 불러올 수 없습니다',
                style: TextStyle(color: SemanticColors.text.secondary),
              ),
            ),
          ),
        ],
      ),
      data: (treatments) {
        if (treatments.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시술 메뉴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...treatments.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceMenuItem(menu: service),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getDisplayDistance(
    AsyncValue<domain.Route?>? routeAsync,
    double? fallbackDistance,
  ) {
    final route = routeAsync?.valueOrNull;
    if (route != null) {
      return route.formattedDistance;
    }
    if (fallbackDistance != null) {
      return '${fallbackDistance.toStringAsFixed(1)}km';
    }
    return null;
  }

  void _navigateToReviewList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ReviewListPage(shopId: shop.id, shopName: shop.name),
      ),
    );
  }

  Widget _buildBottomReservationButton(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.mintGradient,
          boxShadow: [
            BoxShadow(
              color: SemanticColors.overlay.shadowMedium,
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: _bottomButtonHeight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: SemanticColors.button.secondaryText,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
