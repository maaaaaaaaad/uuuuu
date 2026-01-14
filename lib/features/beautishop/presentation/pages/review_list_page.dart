import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';
import 'package:jellomark/features/beautishop/presentation/providers/review_list_provider.dart';
import 'package:jellomark/features/beautishop/presentation/widgets/review_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListNotifierProvider(widget.shopId));

    return Scaffold(
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
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSortTabs(state.sortType),
          const Divider(height: 1),
          Expanded(
            child: _buildReviewList(state),
          ),
        ],
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
            child: ChoiceChip(
              label: Text(
                sortType.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                ref
                    .read(reviewListNotifierProvider(widget.shopId).notifier)
                    .changeSortType(sortType);
              },
              selectedColor: const Color(0xFFFFB5BA),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList(ReviewListState state) {
    if (state.isLoading && state.reviews.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFB5BA),
        ),
      );
    }

    if (state.error != null && state.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref
                    .read(reviewListNotifierProvider(widget.shopId).notifier)
                    .refresh();
              },
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
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '아직 리뷰가 없어요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
      color: const Color(0xFFFFB5BA),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: state.reviews.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == state.reviews.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB5BA),
                ),
              ),
            );
          }

          return ReviewCard(review: state.reviews[index]);
        },
      ),
    );
  }
}
