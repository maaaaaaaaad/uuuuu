import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/presentation/pages/review_list_page.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ReviewSection extends ConsumerStatefulWidget {
  final String shopId;
  final String shopName;

  const ReviewSection({super.key, required this.shopId, required this.shopName});

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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(color: SemanticColors.indicator.loadingPink),
            ),
          )
        else if (state.error != null && state.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '리뷰를 불러올 수 없습니다',
                style: TextStyle(color: SemanticColors.text.secondary),
              ),
            ),
          )
        else if (state.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '아직 리뷰가 없습니다',
                style: TextStyle(color: SemanticColors.text.secondary),
              ),
            ),
          )
        else
          Column(
            children: [
              ...state.reviews
                  .take(3)
                  .map((review) => _ReviewItem(review: review)),
              if (state.reviews.length > 3)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReviewListPage(
                          shopId: widget.shopId,
                          shopName: widget.shopName,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '리뷰 더보기',
                    style: TextStyle(color: SemanticColors.text.linkPink),
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
                backgroundColor: SemanticColors.background.avatar,
                child: Icon(Icons.person, color: SemanticColors.icon.secondary, size: 20),
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
                        if (review.rating != null) ...[
                          _buildRatingStars(review.rating!.toDouble()),
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
          if (review.content != null) ...[
            const SizedBox(height: 10),
            Text(
              review.content!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
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
                      color: SemanticColors.background.avatar,
                      child: Image.network(
                        review.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: SemanticColors.icon.disabled);
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
