import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';
import 'package:jellomark/features/beautishop/presentation/providers/review_list_provider.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/write_review_bottom_sheet.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';

class ReviewListPage extends ConsumerStatefulWidget {
  final String shopId;
  final String shopName;

  const ReviewListPage({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  ConsumerState<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends ConsumerState<ReviewListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewListNotifierProvider(widget.shopId).notifier).loadReviews();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(reviewListNotifierProvider(widget.shopId).notifier).loadMore();
    }
  }

  void _showWriteReviewBottomSheet(BuildContext context) {
    WriteReviewBottomSheet.show(
      context: context,
      shopName: widget.shopName,
      onSubmit: ({int? rating, String? content}) {
        return ref
            .read(reviewListNotifierProvider(widget.shopId).notifier)
            .createReview(rating: rating, content: content);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListNotifierProvider(widget.shopId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.shopName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '리뷰 ${state.totalElements}개',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: SemanticColors.text.secondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.background.appBar,
        foregroundColor: SemanticColors.text.primary,
      ),
      backgroundColor: SemanticColors.special.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSortTabs(state.sortType),
              Expanded(
                child: _buildReviewList(state),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildGradientFab(context),
    );
  }

  Widget _buildGradientFab(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWriteReviewBottomSheet(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.mintGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: SemanticColors.overlay.shadowMedium,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.edit_rounded,
          color: SemanticColors.icon.onDark,
        ),
      ),
    );
  }

  Widget _buildSortTabs(ReviewSortType currentSort) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: ReviewSortType.values.map((sortType) {
          final isSelected = currentSort == sortType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PillChip(
              label: sortType.displayName,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(reviewListNotifierProvider(widget.shopId).notifier)
                    .changeSortType(sortType);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList(ReviewListState state) {
    if (state.isLoading && state.reviews.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      );
    }

    if (state.error != null && state.reviews.isEmpty) {
      return Center(
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
              state.error!,
              style: TextStyle(color: SemanticColors.text.secondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref
                    .read(reviewListNotifierProvider(widget.shopId).notifier)
                    .refresh();
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

    if (state.reviews.isEmpty) {
      return Center(
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
                Icons.rate_review_outlined,
                size: 48,
                color: SemanticColors.icon.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 리뷰가 없어요',
              style: TextStyle(
                fontSize: 16,
                color: SemanticColors.text.secondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showWriteReviewBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.mintGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: SemanticColors.overlay.shadowMedium,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '첫 리뷰 작성하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SemanticColors.text.onDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(reviewListNotifierProvider(widget.shopId).notifier)
            .refresh();
      },
      color: SemanticColors.indicator.loading,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: state.reviews.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == state.reviews.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: SemanticColors.indicator.loading,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ReviewCard(review: state.reviews[index]),
          );
        },
      ),
    );
  }
}
