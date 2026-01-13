import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';

class ReviewSection extends ConsumerStatefulWidget {
  final String shopId;

  const ReviewSection({super.key, required this.shopId});

  @override
  ConsumerState<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends ConsumerState<ReviewSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopReviewsNotifierProvider(widget.shopId).notifier)
          .loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopReviewsNotifierProvider(widget.shopId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '리뷰',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.isLoading && state.reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFFFFB5BA)),
            ),
          )
        else if (state.error != null && state.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '리뷰를 불러올 수 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else if (state.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '아직 리뷰가 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          Column(
            children: [
              ...state.reviews.take(3).map(
                    (review) => _ReviewItem(review: review),
                  ),
              if (state.reviews.length > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all reviews page
                  },
                  child: const Text(
                    '리뷰 더보기',
                    style: TextStyle(color: Color(0xFFFFB5BA)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMemberId(review.memberId),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildRatingStars(review.rating.toDouble()),
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
          const Divider(height: 24),
        ],
      ),
    );
  }

  String _formatMemberId(String memberId) {
    if (memberId.length > 8) {
      return '${memberId.substring(0, 4)}****';
    }
    return memberId;
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
