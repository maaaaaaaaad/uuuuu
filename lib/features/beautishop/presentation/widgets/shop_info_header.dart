import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopInfoHeader extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String? distance;
  final List<String>? tags;
  final String? address;
  final VoidCallback? onReviewTap;

  const ShopInfoHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.reviewCount,
    this.distance,
    this.tags,
    this.address,
    this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildReviewButton(),
              if (distance != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 16, color: SemanticColors.icon.secondary),
                const SizedBox(width: 2),
                Text(
                  distance!,
                  style: TextStyle(
                    fontSize: 14,
                    color: SemanticColors.text.secondary,
                  ),
                ),
              ],
            ],
          ),
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: tags!.map((tag) => _buildTag(tag)).toList(),
            ),
          ],
          if (address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.place, size: 16, color: SemanticColors.icon.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewButton() {
    return Material(
      color: SemanticColors.special.transparent,
      child: InkWell(
        onTap: onReviewTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SemanticColors.special.ratingBadge,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SemanticColors.special.ratingBadgeBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: SemanticColors.icon.starFilled, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SemanticColors.text.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '리뷰 $reviewCount개',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SemanticColors.text.count,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: SemanticColors.text.count,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SemanticColors.special.pinkHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: SemanticColors.special.pinkHighlightText,
        ),
      ),
    );
  }
}
