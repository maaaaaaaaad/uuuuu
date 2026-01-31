import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/full_screen_image_viewer.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_image_gallery.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_map_widget.dart';
import 'package:jellomark/features/location/domain/entities/route.dart'
    as domain;
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopDetailPage extends ConsumerStatefulWidget {
  final ShopDetail shopDetail;
  final List<ServiceMenu> services;
  final List<ShopReview> reviews;

  const ShopDetailPage({
    super.key,
    required this.shopDetail,
    required this.services,
    required this.reviews,
  });

  factory ShopDetailPage.fromBeautyShop({Key? key, required BeautyShop shop}) {
    String phoneNumber = '';
    String? description;
    Map<String, String>? operatingHoursMap;

    if (shop is BeautyShopModel) {
      phoneNumber = shop.phoneNumber;
      description = shop.description;
      operatingHoursMap = shop.operatingTimeMap;
    }

    final shopDetail = ShopDetail(
      id: shop.id,
      name: shop.name,
      address: shop.address,
      description: description ?? '',
      phoneNumber: phoneNumber,
      images: shop.images,
      operatingHoursMap: operatingHoursMap,
      rating: shop.rating,
      reviewCount: shop.reviewCount,
      distance: shop.distance,
      tags: shop.tags,
      discountRate: shop.discountRate,
      isNew: shop.isNew,
      latitude: shop.latitude,
      longitude: shop.longitude,
    );

    return ShopDetailPage(
      key: key,
      shopDetail: shopDetail,
      services: const [],
      reviews: const [],
    );
  }

  @override
  ConsumerState<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends ConsumerState<ShopDetailPage> {
  List<domain.LatLng>? _routePath;
  bool _isLoadingRoute = false;
  bool _routeFetchAttempted = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);

    locationAsync.whenData((userLocation) {
      if (userLocation != null && !_routeFetchAttempted) {
        _fetchRoute(userLocation.latitude, userLocation.longitude);
      }
    });

    return Scaffold(
      body: _buildBackdropMapLayout(context, locationAsync),
      bottomSheet: _buildBottomReservationButton(context),
    );
  }

  Widget _buildBackdropMapLayout(
    BuildContext context,
    AsyncValue<dynamic> locationAsync,
  ) {
    final shopLat = widget.shopDetail.latitude;
    final shopLng = widget.shopDetail.longitude;

    if (shopLat == null || shopLng == null) {
      return _buildFallbackScrollView(context);
    }

    final userLocation = locationAsync.valueOrNull;

    return Stack(
      children: [
        Positioned.fill(
          child: ShopMapWidget(
            shopLatitude: shopLat,
            shopLongitude: shopLng,
            shopName: widget.shopDetail.name,
            userLatitude: userLocation?.latitude,
            userLongitude: userLocation?.longitude,
            routeCoordinates: _routePath,
            interactiveMode: true,
          ),
        ),

        DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          snap: true,
          snapSizes: const [0.3, 0.6, 1.0],
          builder: (context, scrollController) {
            return _buildSheetContent(context, scrollController);
          },
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: _buildBackButton(context),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SemanticColors.background.input.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: SemanticColors.overlay.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SemanticColors.background.input,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: SemanticColors.overlay.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDragHandle(),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.shopDetail.images.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ShopImageGallery(
                          images: widget.shopDetail.images,
                          onImageTap: (index) => _openFullScreenViewer(index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ShopInfoHeader(
                    name: widget.shopDetail.name,
                    rating: widget.shopDetail.rating,
                    reviewCount: widget.shopDetail.reviewCount,
                    distance: widget.shopDetail.distance != null
                        ? '${widget.shopDetail.distance!.toStringAsFixed(1)}km'
                        : null,
                    address: widget.shopDetail.address,
                  ),

                  if (_isLoadingRoute) ...[
                    const SizedBox(height: 12),
                    _buildRouteLoadingIndicator(),
                  ],

                  if (widget.shopDetail.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ShopDescription(description: widget.shopDetail.description),
                  ],

                  if (widget.shopDetail.operatingHoursMap != null &&
                      widget.shopDetail.operatingHoursMap!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    OperatingHoursCard(
                      operatingHours: widget.shopDetail.operatingHoursMap!,
                    ),
                  ],

                  if (widget.services.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildServiceMenuSection(),
                  ],

                  if (widget.reviews.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildReviewSection(),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildRouteLoadingIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SemanticColors.icon.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '경로 계산 중...',
          style: TextStyle(fontSize: 12, color: SemanticColors.text.secondary),
        ),
      ],
    );
  }

  Widget _buildFallbackScrollView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopInfoHeader(
                  name: widget.shopDetail.name,
                  rating: widget.shopDetail.rating,
                  reviewCount: widget.shopDetail.reviewCount,
                  distance: widget.shopDetail.distance != null
                      ? '${widget.shopDetail.distance!.toStringAsFixed(1)}km'
                      : null,
                  address: widget.shopDetail.address,
                ),
                if (widget.shopDetail.description.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ShopDescription(description: widget.shopDetail.description),
                ],
                if (widget.shopDetail.operatingHoursMap != null &&
                    widget.shopDetail.operatingHoursMap!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  OperatingHoursCard(
                    operatingHours: widget.shopDetail.operatingHoursMap!,
                  ),
                ],
                if (widget.services.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildServiceMenuSection(),
                ],
                if (widget.reviews.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildReviewSection(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SliverAppBar(
      expandedHeight: widget.shopDetail.images.isNotEmpty
          ? screenWidth
          : kToolbarHeight,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed =
              constraints.maxHeight <=
              kToolbarHeight + MediaQuery.of(context).padding.top;
          return FlexibleSpaceBar(
            title: isCollapsed ? Text(widget.shopDetail.name) : null,
            background: widget.shopDetail.images.isNotEmpty
                ? ShopImageGallery(
                    images: widget.shopDetail.images,
                    onImageTap: (index) => _openFullScreenViewer(index),
                  )
                : Container(color: SemanticColors.background.cardPink),
          );
        },
      ),
    );
  }

  Widget _buildServiceMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시술 메뉴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ServiceMenuItem(menu: service),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.shopDetail.reviewCount > 0)
              Text(
                '${widget.shopDetail.reviewCount}개',
                style: TextStyle(
                  fontSize: 14,
                  color: SemanticColors.text.secondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.reviews.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReviewCard(review: review),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomReservationButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SemanticColors.background.input,
        boxShadow: [
          BoxShadow(
            color: SemanticColors.overlay.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: SemanticColors.button.primary,
              foregroundColor: SemanticColors.button.primaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '예약하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullScreenViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: widget.shopDetail.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _fetchRoute(double userLat, double userLng) async {
    final shopLat = widget.shopDetail.latitude;
    final shopLng = widget.shopDetail.longitude;

    if (shopLat == null || shopLng == null) return;
    if (_routeFetchAttempted) return;

    setState(() {
      _isLoadingRoute = true;
      _routeFetchAttempted = true;
    });

    debugPrint(
      '[ShopDetailPage] Fetching route: user=($userLat, $userLng) -> shop=($shopLat, $shopLng)',
    );

    try {
      final params = RouteParams(
        startLat: userLat,
        startLng: userLng,
        endLat: shopLat,
        endLng: shopLng,
      );

      final route = await ref.read(routeProvider(params).future);

      if (mounted) {
        setState(() {
          _routePath = route?.coordinates;
          _isLoadingRoute = false;
        });
        debugPrint(
          '[ShopDetailPage] Route fetched: ${_routePath?.length ?? 0} coordinates',
        );
      }
    } catch (e) {
      debugPrint('[ShopDetailPage] Route fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }
}
