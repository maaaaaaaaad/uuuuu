import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';

class ReviewListState extends Equatable {
  final List<ShopReview> reviews;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int totalElements;
  final int currentPage;
  final ReviewSortType sortType;
  final String? error;

  const ReviewListState({
    this.reviews = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.totalElements = 0,
    this.currentPage = 0,
    this.sortType = ReviewSortType.createdAtDesc,
    this.error,
  });

  ReviewListState copyWith({
    List<ShopReview>? reviews,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? totalElements,
    int? currentPage,
    ReviewSortType? sortType,
    String? error,
  }) {
    return ReviewListState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      sortType: sortType ?? this.sortType,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    isLoading,
    isLoadingMore,
    hasNext,
    totalElements,
    currentPage,
    sortType,
    error,
  ];
}

final getShopReviewsUseCaseProvider = Provider<GetShopReviews>((ref) {
  return sl<GetShopReviews>();
});

class ReviewListNotifier extends StateNotifier<ReviewListState> {
  final GetShopReviews _getShopReviews;
  final String shopId;

  ReviewListNotifier({
    required GetShopReviews getShopReviews,
    required this.shopId,
  }) : _getShopReviews = getShopReviews,
       super(const ReviewListState());

  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getShopReviews(
      shopId: shopId,
      page: 0,
      sort: state.sortType,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedReviews) {
        state = state.copyWith(
          reviews: pagedReviews.items,
          hasNext: pagedReviews.hasNext,
          totalElements: pagedReviews.totalElements,
          currentPage: 0,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _getShopReviews(
      shopId: shopId,
      page: nextPage,
      sort: state.sortType,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure.message);
      },
      (pagedReviews) {
        state = state.copyWith(
          reviews: [...state.reviews, ...pagedReviews.items],
          hasNext: pagedReviews.hasNext,
          totalElements: pagedReviews.totalElements,
          currentPage: nextPage,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> changeSortType(ReviewSortType sortType) async {
    if (state.sortType == sortType) return;

    state = state.copyWith(
      sortType: sortType,
      reviews: [],
      currentPage: 0,
      hasNext: true,
    );

    await loadReviews();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      reviews: [],
      currentPage: 0,
      hasNext: true,
      error: null,
    );
    await loadReviews();
  }
}

final reviewListNotifierProvider = StateNotifierProvider.autoDispose
    .family<ReviewListNotifier, ReviewListState, String>((ref, shopId) {
      return ReviewListNotifier(
        getShopReviews: ref.watch(getShopReviewsUseCaseProvider),
        shopId: shopId,
      );
    });
