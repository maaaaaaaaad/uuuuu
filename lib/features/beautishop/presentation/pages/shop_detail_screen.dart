import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/presentation/pages/review_list_page.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_image_gallery.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';
import 'package:jellomark/features/review/presentation/widgets/review_section.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';

class ShopDetailScreen extends ConsumerWidget {
  final BeautyShop shop;

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

    void navigateToReviewList() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ReviewListPage(shopId: shop.id, shopName: shop.name),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, shopDetail),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShopInfoHeader(
                    name: shopDetail.name,
                    rating: shopDetail.rating,
                    reviewCount: shopDetail.reviewCount,
                    distance: shopDetail.distance != null
                        ? '${shopDetail.distance!.toStringAsFixed(1)}km'
                        : null,
                    address: shopDetail.address,
                    onReviewTap: navigateToReviewList,
                  ),
                  if (shopDetail.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ShopDescription(description: shopDetail.description),
                  ],
                  if (shopDetail.operatingHoursMap != null &&
                      shopDetail.operatingHoursMap!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    OperatingHoursCard(
                      operatingHours: shopDetail.operatingHoursMap!,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildServiceMenuSection(treatmentsAsync),
                  const SizedBox(height: 24),
                  ReviewSection(shopId: shop.id),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomReservationButton(context),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, ShopDetail shopDetail) {
    return SliverAppBar(
      expandedHeight: shopDetail.images.isNotEmpty ? 250 : kToolbarHeight,
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
            title: isCollapsed ? Text(shopDetail.name) : null,
            background: shopDetail.images.isNotEmpty
                ? ShopImageGallery(images: shopDetail.images)
                : Container(
                    color: const Color(0xFFFFB5BA).withValues(alpha: 0.3),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildServiceMenuSection(
    AsyncValue<List<ServiceMenu>> treatmentsAsync,
  ) {
    return treatmentsAsync.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시술 메뉴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFFFFB5BA)),
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
                style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildBottomReservationButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              backgroundColor: const Color(0xFFFFB5BA),
              foregroundColor: Colors.white,
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
}
