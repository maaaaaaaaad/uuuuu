import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/beautishop/presentation/providers/shop_provider.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/full_screen_image_viewer.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/features/review/presentation/widgets/edit_review_bottom_sheet.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/widgets/glass_card.dart';
import 'package:jellomark/shared/widgets/units/app_cached_image.dart';

class MyReviewsPage extends ConsumerStatefulWidget {
  const MyReviewsPage({super.key});

  @override
  ConsumerState<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends ConsumerState<MyReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myReviewsNotifierProvider.notifier).loadInitial();
      ref.read(favoritesNotifierProvider.notifier).loadFavorites();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(myReviewsNotifierProvider.notifier).loadInitial();
  }

  void _showEditSheet(Review review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SemanticColors.special.transparent,
      builder: (sheetContext) => EditReviewBottomSheet(
        initialRating: review.rating,
        initialContent: review.content,
        onSubmit: ({int? rating, String? content}) async {
          final success = await ref
              .read(myReviewsNotifierProvider.notifier)
              .updateReview(
                shopId: review.shopId,
                reviewId: review.id,
                rating: rating,
                content: content,
              );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('리뷰가 수정되었습니다')),
            );
          }
          return success;
        },
      ),
    );
  }

  Future<void> _navigateToShopDetail(Review review) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      ),
    );

    try {
      final shop = await ref.read(shopByIdProvider(review.shopId).future);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('샵 정보를 불러올 수 없습니다')),
        );
      }
    }
  }

  void _openImageViewer(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰 삭제'),
        content: const Text('이 리뷰를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SemanticColors.state.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(myReviewsNotifierProvider.notifier)
          .deleteReview(
            shopId: review.shopId,
            reviewId: review.id,
          );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 삭제되었습니다')),
        );
      }
    }
  }

  bool _isFavorite(String shopId) {
    final favoritesState = ref.watch(favoritesNotifierProvider);
    return favoritesState.items.any((f) => f.shopId == shopId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReviewsNotifierProvider);

    return Scaffold(
      backgroundColor: SemanticColors.special.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('내가 쓴 리뷰'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.special.transparent,
        foregroundColor: SemanticColors.text.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: _buildContent(state),
        ),
      ),
    );
  }

  Widget _buildContent(MyReviewsState state) {
    if (state.isLoading) {
      return _buildSkeletonList();
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (state.reviews.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              ref.read(myReviewsNotifierProvider.notifier).loadMore();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.reviews.length + _getExtraItemCount(state),
          itemBuilder: (context, index) {
            if (index == state.reviews.length) {
              if (state.loadMoreError != null) {
                return _buildLoadMoreError();
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: SemanticColors.indicator.loading,
                  ),
                ),
              );
            }

            final review = state.reviews[index];
            return _buildReviewCard(review);
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final isFavorite = _isFavorite(review.shopId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        onTap: () => _navigateToShopDetail(review),
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopHeader(review, isFavorite),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingRow(review),
                  if (review.content != null && review.content!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      review.content!,
                      style: TextStyle(
                        fontSize: 14,
                        color: SemanticColors.text.primary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (review.hasImages) ...[
                    const SizedBox(height: 12),
                    _buildImageRow(review),
                  ],
                  const SizedBox(height: 12),
                  _buildFooter(review),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader(Review review, bool isFavorite) {
    return Stack(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SemanticColors.background.cardPink,
                SemanticColors.background.card,
              ],
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: review.shopImage != null
                      ? AppCachedImage(
                          imageUrl: review.shopImage!,
                          width: 56,
                          height: 56,
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: SemanticColors.background.imagePlaceholder,
                          child: Icon(
                            Icons.storefront,
                            color: SemanticColors.icon.disabled,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.shopName ?? '샵 이름 없음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SemanticColors.text.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: SemanticColors.icon.secondary,
                        ),
                        Text(
                          '샵 상세보기',
                          style: TextStyle(
                            fontSize: 12,
                            color: SemanticColors.text.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isFavorite)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                size: 16,
                color: SemanticColors.icon.accentPink,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingRow(Review review) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (review.rating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SemanticColors.special.ratingBadge,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: SemanticColors.special.ratingBadgeBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < review.rating! ? Icons.star : Icons.star_border,
                    size: 16,
                    color: i < review.rating!
                        ? SemanticColors.icon.starFilled
                        : SemanticColors.icon.starEmpty,
                  );
                }),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.edit_outlined,
              onTap: () => _showEditSheet(review),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.delete_outline,
              onTap: () => _showDeleteConfirmation(review),
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? SemanticColors.state.error.withValues(alpha: 0.1)
              : SemanticColors.background.chip,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive
              ? SemanticColors.state.error
              : SemanticColors.icon.secondary,
        ),
      ),
    );
  }

  Widget _buildImageRow(Review review) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openImageViewer(review.images, index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppCachedImage(
                imageUrl: review.images[index],
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(Review review) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: SemanticColors.icon.disabled,
            ),
            const SizedBox(width: 4),
            Text(
              review.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: SemanticColors.text.secondary,
              ),
            ),
            if (review.isEdited) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SemanticColors.background.chip,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '수정됨',
                  style: TextStyle(
                    fontSize: 10,
                    color: SemanticColors.text.disabled,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (review.hasImages)
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 14,
                color: SemanticColors.icon.disabled,
              ),
              const SizedBox(width: 4),
              Text(
                '${review.images.length}장',
                style: TextStyle(
                  fontSize: 12,
                  color: SemanticColors.text.secondary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppGradients.pinkGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: SemanticColors.text.onDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '작성한 리뷰가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '방문한 샵에 리뷰를 남겨보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: TextStyle(
                      fontSize: 16,
                      color: SemanticColors.text.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _onRefresh,
                    style: TextButton.styleFrom(
                      foregroundColor: SemanticColors.button.textButton,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _getExtraItemCount(MyReviewsState state) {
    if (state.isLoadingMore || state.loadMoreError != null) {
      return 1;
    }
    return 0;
  }

  Widget _buildLoadMoreError() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '더 불러오지 못했습니다',
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(myReviewsNotifierProvider.notifier).loadMore();
            },
            style: TextButton.styleFrom(
              foregroundColor: SemanticColors.button.textButton,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: SemanticColors.background.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SemanticColors.border.glass),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: SemanticColors.background.skeleton,
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildSkeletonBox(width: 56, height: 56, radius: 12),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonBox(width: 120, height: 16),
                      const SizedBox(height: 8),
                      _buildSkeletonBox(width: 80, height: 12),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(width: 100, height: 28, radius: 20),
                  const SizedBox(height: 12),
                  _buildSkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  _buildSkeletonBox(width: 200, height: 14),
                  const SizedBox(height: 12),
                  _buildSkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SemanticColors.background.skeleton,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
