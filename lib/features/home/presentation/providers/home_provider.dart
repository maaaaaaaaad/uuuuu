import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';

class HomeState extends Equatable {
  final List<BeautyShop> recommendedShops;
  final List<BeautyShop> newShops;
  final List<BeautyShop> nearbyShops;
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final int newShopsPage;
  final bool hasMoreNewShops;
  final bool isLoadingMoreNewShops;
  final bool hasMoreRecommended;

  static const int recommendedDisplayLimit = 5;

  const HomeState({
    this.recommendedShops = const [],
    this.newShops = const [],
    this.nearbyShops = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.newShopsPage = 0,
    this.hasMoreNewShops = true,
    this.isLoadingMoreNewShops = false,
    this.hasMoreRecommended = false,
  });

  List<BeautyShop> get displayedRecommendedShops =>
      recommendedShops.take(recommendedDisplayLimit).toList();

  HomeState copyWith({
    List<BeautyShop>? recommendedShops,
    List<BeautyShop>? newShops,
    List<BeautyShop>? nearbyShops,
    List<Category>? categories,
    bool? isLoading,
    String? error,
    int? newShopsPage,
    bool? hasMoreNewShops,
    bool? isLoadingMoreNewShops,
    bool? hasMoreRecommended,
  }) {
    return HomeState(
      recommendedShops: recommendedShops ?? this.recommendedShops,
      newShops: newShops ?? this.newShops,
      nearbyShops: nearbyShops ?? this.nearbyShops,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      newShopsPage: newShopsPage ?? this.newShopsPage,
      hasMoreNewShops: hasMoreNewShops ?? this.hasMoreNewShops,
      isLoadingMoreNewShops:
          isLoadingMoreNewShops ?? this.isLoadingMoreNewShops,
      hasMoreRecommended: hasMoreRecommended ?? this.hasMoreRecommended,
    );
  }

  @override
  List<Object?> get props => [
    recommendedShops,
    newShops,
    nearbyShops,
    categories,
    isLoading,
    error,
    newShopsPage,
    hasMoreNewShops,
    isLoadingMoreNewShops,
    hasMoreRecommended,
  ];
}

final getFilteredShopsUseCaseProvider = Provider<GetFilteredShopsUseCase>((
  ref,
) {
  return sl<GetFilteredShopsUseCase>();
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return sl<GetCategoriesUseCase>();
});

class HomeNotifier extends StateNotifier<HomeState> {
  final GetFilteredShopsUseCase _getFilteredShopsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  HomeNotifier({
    required GetFilteredShopsUseCase getFilteredShopsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  }) : _getFilteredShopsUseCase = getFilteredShopsUseCase,
       _getCategoriesUseCase = getCategoriesUseCase,
       super(const HomeState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    final categoriesResult = await _getCategoriesUseCase();
    categoriesResult.fold(
      (failure) {},
      (categories) {
        state = state.copyWith(categories: categories);
      },
    );

    const nearbyShopsFilter = BeautyShopFilter(
      sortBy: 'RATING',
      sortOrder: 'DESC',
      minRating: 4.0,
      size: 10,
    );
    final nearbyResult = await _getFilteredShopsUseCase(nearbyShopsFilter);
    nearbyResult.fold(
      (failure) {},
      (pagedShops) {
        state = state.copyWith(nearbyShops: pagedShops.items);
      },
    );

    const recommendedFilter = BeautyShopFilter(
      sortBy: 'RATING',
      sortOrder: 'DESC',
      size: HomeState.recommendedDisplayLimit + 1,
    );
    final recommendedResult = await _getFilteredShopsUseCase(recommendedFilter);
    recommendedResult.fold(
      (failure) {},
      (pagedShops) {
        final hasMore =
            pagedShops.items.length > HomeState.recommendedDisplayLimit ||
                pagedShops.hasNext;
        state = state.copyWith(
          recommendedShops: pagedShops.items,
          hasMoreRecommended: hasMore,
        );
      },
    );

    const newShopsFilter = BeautyShopFilter(
      sortBy: 'CREATED_AT',
      sortOrder: 'DESC',
      size: 10,
    );
    final newShopsResult = await _getFilteredShopsUseCase(newShopsFilter);
    newShopsResult.fold(
      (failure) {},
      (pagedShops) {
        state = state.copyWith(
          newShops: pagedShops.items,
          hasMoreNewShops: pagedShops.hasNext,
          newShopsPage: 0,
        );
      },
    );

    state = state.copyWith(isLoading: false);
  }

  Future<void> loadMoreNewShops() async {
    if (!state.hasMoreNewShops || state.isLoadingMoreNewShops) return;

    state = state.copyWith(isLoadingMoreNewShops: true);

    final nextPage = state.newShopsPage + 1;
    final filter = BeautyShopFilter(
      sortBy: 'CREATED_AT',
      sortOrder: 'DESC',
      size: 10,
      page: nextPage,
    );

    final result = await _getFilteredShopsUseCase(filter);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMoreNewShops: false,
          error: failure.message,
        );
      },
      (pagedShops) {
        state = state.copyWith(
          newShops: [...state.newShops, ...pagedShops.items],
          hasMoreNewShops: pagedShops.hasNext,
          newShopsPage: nextPage,
          isLoadingMoreNewShops: false,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(
      error: null,
      newShopsPage: 0,
      hasMoreNewShops: true,
    );
    await loadData();
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((
  ref,
) {
  return HomeNotifier(
    getFilteredShopsUseCase: ref.watch(getFilteredShopsUseCaseProvider),
    getCategoriesUseCase: ref.watch(getCategoriesUseCaseProvider),
  );
});
