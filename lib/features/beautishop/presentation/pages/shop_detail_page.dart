import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/operating_hours_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/service_menu_item.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_description.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_image_gallery.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/shop_info_header.dart';

class ShopDetailPage extends StatelessWidget {
  final ShopDetail shopDetail;
  final List<ServiceMenu> services;
  final List<ShopReview> reviews;

  const ShopDetailPage({
    super.key,
    required this.shopDetail,
    required this.services,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
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
                  ),
                  const SizedBox(height: 24),
                  ShopDescription(description: shopDetail.description),
                  const SizedBox(height: 24),
                  if (shopDetail.operatingHoursMap != null)
                    OperatingHoursCard(
                      operatingHours: shopDetail.operatingHoursMap!,
                    ),
                  const SizedBox(height: 24),
                  _buildServiceMenuSection(),
                  const SizedBox(height: 24),
                  _buildReviewSection(),
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
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
            background: ShopImageGallery(images: shopDetail.images),
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
        ...services.map(
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
            Text(
              '리뷰',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (shopDetail.reviewCount > 0)
              Text(
                '${shopDetail.reviewCount}개',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...reviews.map(
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
