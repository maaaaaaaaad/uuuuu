import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/shared/widgets/units/card_3d.dart';

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
    return Card3D(
      onTap: onTap,
      padding: EdgeInsets.zero,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
            color: Colors.grey[200],
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
                    color: Colors.grey[400],
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
                color: const Color(0xFFFF8A94),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${shop.discountRate}%',
                style: const TextStyle(
                  color: Colors.white,
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
                color: const Color(0xFFFFB5BA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
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
        const Icon(
          Icons.star,
          size: 14,
          color: Color(0xFFFFB5BA),
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
            color: Colors.grey[500],
          ),
          Text(
            shop.formattedDistance!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
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
            color: const Color(0xFFFFE4E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFFF8A94),
            ),
          ),
        );
      }).toList(),
    );
  }
}
