import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/shared/widgets/units/section_header.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';

class HorizontalShopSection extends StatelessWidget {
  final String title;
  final List<BeautyShop> shops;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final void Function(String id)? onShopTap;

  const HorizontalShopSection({
    super.key,
    required this.title,
    required this.shops,
    this.showMore = false,
    this.onMoreTap,
    this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          showMore: showMore,
          onMoreTap: onMoreTap,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ShopCard(
                  shop: shop,
                  width: 180,
                  onTap: () => onShopTap?.call(shop.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class VerticalShopSection extends StatelessWidget {
  final String title;
  final List<BeautyShop> shops;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final void Function(String id)? onShopTap;

  const VerticalShopSection({
    super.key,
    required this.title,
    required this.shops,
    this.showMore = false,
    this.onMoreTap,
    this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          showMore: showMore,
          onMoreTap: onMoreTap,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShopCard(
                shop: shop,
                width: double.infinity,
                onTap: () => onShopTap?.call(shop.id),
              ),
            );
          },
        ),
      ],
    );
  }
}
