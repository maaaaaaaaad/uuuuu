import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: review.authorProfileImage != null
                      ? NetworkImage(review.authorProfileImage!)
                      : null,
                  child: review.authorProfileImage == null
                      ? Icon(Icons.person, color: Colors.grey[600], size: 20)
                      : null,
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
                          _buildRatingStars(review.rating),
                          const SizedBox(width: 8),
                          Text(
                            review.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review.serviceName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              review.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Image.network(
                          review.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              color: Colors.grey[500],
                            );
                          },
                        ),
                      ),
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
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: 14, color: Colors.grey[400]);
        }
      }),
    );
  }
}
