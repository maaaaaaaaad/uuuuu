import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/units/app_cached_image.dart';

class ReviewCard extends StatelessWidget {
  final ShopReview review;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCachedAvatar(
                  imageUrl: review.authorProfileImage,
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (review.hasRating) ...[
                            _buildRatingStars(review.rating!),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            review.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: SemanticColors.text.disabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.serviceName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SemanticColors.background.chip,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review.serviceName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: SemanticColors.icon.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (review.hasContent)
              Text(
                review.content!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              )
            else if (review.isRatingOnly)
              Text(
                '평점만 등록됨',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: SemanticColors.text.disabled,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (review.hasImages) ...[
              const SizedBox(height: 10),
              SizedBox(
                key: const Key('review_images'),
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return AppCachedImage(
                      imageUrl: review.images[index],
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(8),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: 14, color: SemanticColors.icon.starFilled);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: 14, color: SemanticColors.icon.starFilled);
        } else {
          return Icon(Icons.star_border, size: 14, color: SemanticColors.icon.starEmpty);
        }
      }),
    );
  }
}
