import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';

class ShopCard extends StatelessWidget {
  final BeautyShop shop;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const ShopCard({
    super.key,
    required this.shop,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: 16,
      backgroundColor: SemanticColors.background.cardAccent,
      child: SizedBox(
        width: width ?? 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: SemanticColors.text.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildRatingAndDistance(),
                  if (shop.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTags(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            color: SemanticColors.background.imagePlaceholder,
            image: shop.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(shop.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: shop.imageUrl == null
              ? Center(
                  child: Icon(
                    Icons.storefront,
                    size: 40,
                    color: SemanticColors.icon.disabled,
                  ),
                )
              : null,
        ),
        if (shop.discountRate != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SemanticColors.special.tagDiscount,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${shop.discountRate}%',
                style: TextStyle(
                  color: SemanticColors.special.tagDiscountText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (shop.isNew)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SemanticColors.special.tagNew,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  color: SemanticColors.special.tagNewText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingAndDistance() {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 14,
          color: SemanticColors.icon.starSelectable,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            '${shop.formattedRating} (${shop.reviewCount})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (shop.distance != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.location_on,
            size: 14,
            color: SemanticColors.icon.disabled,
          ),
          Flexible(
            child: Text(
              shop.formattedDistance!,
              style: TextStyle(
                fontSize: 12,
                color: SemanticColors.text.hint,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: shop.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: SemanticColors.special.badge,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: SemanticColors.special.badgeText,
            ),
          ),
        );
      }).toList(),
    );
  }
}
