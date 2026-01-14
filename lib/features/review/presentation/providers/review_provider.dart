import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/usecases/create_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/delete_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/update_review_usecase.dart';

final getShopReviewsUseCaseProvider = Provider<GetShopReviewsUseCase>((ref) {
  return sl<GetShopReviewsUseCase>();
});

final createReviewUseCaseProvider = Provider<CreateReviewUseCase>((ref) {
  return sl<CreateReviewUseCase>();
});

final updateReviewUseCaseProvider = Provider<UpdateReviewUseCase>((ref) {
  return sl<UpdateReviewUseCase>();
});

final deleteReviewUseCaseProvider = Provider<DeleteReviewUseCase>((ref) {
  return sl<DeleteReviewUseCase>();
});

class ShopReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const ShopReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  ShopReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return ShopReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class ShopReviewsNotifier extends StateNotifier<ShopReviewsState> {
  final String shopId;
  final Ref _ref;

  ShopReviewsNotifier(this.shopId, this._ref) : super(const ShopReviewsState());

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getShopReviewsUseCaseProvider);
    final result = await useCase(shopId: shopId, page: 0);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedReviews) {
        state = state.copyWith(
          reviews: pagedReviews.items,
          hasMore: pagedReviews.hasNext,
          page: 0,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final useCase = _ref.read(getShopReviewsUseCaseProvider);
    final result = await useCase(shopId: shopId, page: nextPage);

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure.message);
      },
      (pagedReviews) {
        state = state.copyWith(
          reviews: [...state.reviews, ...pagedReviews.items],
          hasMore: pagedReviews.hasNext,
          page: nextPage,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<bool> createReview({
    required int rating,
    required String content,
    List<String>? images,
  }) async {
    final useCase = _ref.read(createReviewUseCaseProvider);
    final result = await useCase(
      shopId: shopId,
      rating: rating,
      content: content,
      images: images,
    );

    return result.fold((failure) => false, (review) {
      state = state.copyWith(reviews: [review, ...state.reviews]);
      return true;
    });
  }

  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    required String content,
    List<String>? images,
  }) async {
    final useCase = _ref.read(updateReviewUseCaseProvider);
    final result = await useCase(
      shopId: shopId,
      reviewId: reviewId,
      rating: rating,
      content: content,
      images: images,
    );

    return result.fold((failure) => false, (updatedReview) {
      final updatedReviews = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();
      state = state.copyWith(reviews: updatedReviews);
      return true;
    });
  }

  Future<bool> deleteReview(String reviewId) async {
    final useCase = _ref.read(deleteReviewUseCaseProvider);
    final result = await useCase(shopId: shopId, reviewId: reviewId);

    return result.fold((failure) => false, (_) {
      final updatedReviews = state.reviews
          .where((r) => r.id != reviewId)
          .toList();
      state = state.copyWith(reviews: updatedReviews);
      return true;
    });
  }
}

final shopReviewsNotifierProvider = StateNotifierProvider.autoDispose
    .family<ShopReviewsNotifier, ShopReviewsState, String>(
      (ref, shopId) => ShopReviewsNotifier(shopId, ref),
    );
