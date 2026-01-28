import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';

class SearchState extends Equatable {
  final String query;
  final List<BeautyShop> results;
  final List<SearchHistory> searchHistory;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;
  final String? categoryId;
  final String sortBy;
  final String sortOrder;
  final double? minRating;
  final double? latitude;
  final double? longitude;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 0,
    this.isLoadingMore = false,
    this.categoryId,
    this.sortBy = 'RATING',
    this.sortOrder = 'DESC',
    this.minRating,
    this.latitude,
    this.longitude,
  });

  int get activeFilterCount {
    int count = 0;
    if (categoryId != null) count++;
    if (minRating != null) count++;
    if (sortBy != 'RATING') count++;
    return count;
  }

  SearchState copyWith({
    String? query,
    List<BeautyShop>? results,
    List<SearchHistory>? searchHistory,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
    String? categoryId,
    bool clearCategoryId = false,
    String? sortBy,
    String? sortOrder,
    double? minRating,
    bool clearMinRating = false,
    double? latitude,
    double? longitude,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    query,
    results,
    searchHistory,
    isLoading,
    error,
    hasMore,
    page,
    isLoadingMore,
    categoryId,
    sortBy,
    sortOrder,
    minRating,
    latitude,
    longitude,
  ];
}

class SearchNotifier extends StateNotifier<SearchState> {
  final GetFilteredShopsUseCase _getFilteredShopsUseCase;
  final ManageSearchHistoryUseCase _manageSearchHistoryUseCase;

  SearchNotifier({
    required GetFilteredShopsUseCase getFilteredShopsUseCase,
    required ManageSearchHistoryUseCase manageSearchHistoryUseCase,
  }) : _getFilteredShopsUseCase = getFilteredShopsUseCase,
       _manageSearchHistoryUseCase = manageSearchHistoryUseCase,
       super(const SearchState());

  Future<void> loadSearchHistory() async {
    final result = await _manageSearchHistoryUseCase.getSearchHistory();
    result.fold((failure) {}, (history) {
      state = state.copyWith(searchHistory: history);
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      query: query,
      page: 0,
      results: [],
      hasMore: true,
      error: null,
    );

    await _manageSearchHistoryUseCase.saveSearchHistory(query);

    double? latitude;
    double? longitude;

    try {
      final locationUseCase = sl<GetCurrentLocationUseCase>();
      final locationResult = await locationUseCase();
      locationResult.fold(
        (failure) {},
        (location) {
          latitude = location.latitude;
          longitude = location.longitude;
        },
      );
    } catch (_) {}

    state = state.copyWith(latitude: latitude, longitude: longitude);

    final filter = BeautyShopFilter(
      keyword: query,
      sortBy: state.sortBy,
      sortOrder: state.sortBy == 'DISTANCE' ? 'ASC' : state.sortOrder,
      categoryId: state.categoryId,
      minRating: state.minRating,
      latitude: latitude,
      longitude: longitude,
      page: 0,
    );

    final result = await _getFilteredShopsUseCase(filter);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedShops) {
        state = state.copyWith(
          isLoading: false,
          results: pagedShops.items,
          hasMore: pagedShops.hasNext,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    if (state.query.isEmpty && state.activeFilterCount == 0) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final filter = BeautyShopFilter(
      keyword: state.query.isEmpty ? null : state.query,
      sortBy: state.sortBy,
      sortOrder: state.sortBy == 'DISTANCE' ? 'ASC' : state.sortOrder,
      categoryId: state.categoryId,
      minRating: state.minRating,
      latitude: state.latitude,
      longitude: state.longitude,
      page: nextPage,
    );

    final result = await _getFilteredShopsUseCase(filter);
    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure.message);
      },
      (pagedShops) {
        state = state.copyWith(
          isLoadingMore: false,
          results: [...state.results, ...pagedShops.items],
          hasMore: pagedShops.hasNext,
          page: nextPage,
        );
      },
    );
  }

  Future<void> deleteHistory(String keyword) async {
    await _manageSearchHistoryUseCase.deleteSearchHistory(keyword);
    await loadSearchHistory();
  }

  Future<void> clearHistory() async {
    await _manageSearchHistoryUseCase.clearAllSearchHistory();
    state = state.copyWith(searchHistory: []);
  }

  void clearSearch() {
    state = state.copyWith(query: '', results: [], page: 0, hasMore: true);
  }

  void setCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategoryId: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setSort(String sortBy, String sortOrder) {
    state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);
  }

  void setMinRating(double? rating) {
    if (rating == null) {
      state = state.copyWith(clearMinRating: true);
    } else {
      state = state.copyWith(minRating: rating);
    }
  }

  void resetFilters() {
    state = state.copyWith(
      clearCategoryId: true,
      clearMinRating: true,
      sortBy: 'RATING',
      sortOrder: 'DESC',
    );
  }

  Future<void> applyFilters() async {
    state = state.copyWith(
      isLoading: true,
      page: 0,
      results: [],
      hasMore: true,
      error: null,
    );

    double? latitude;
    double? longitude;

    try {
      final locationUseCase = sl<GetCurrentLocationUseCase>();
      final locationResult = await locationUseCase();
      locationResult.fold(
        (failure) {
          debugPrint('[SearchNotifier] Location failed: ${failure.message}');
        },
        (location) {
          latitude = location.latitude;
          longitude = location.longitude;
          debugPrint('[SearchNotifier] Location: $latitude, $longitude');
        },
      );
    } catch (e) {
      debugPrint('[SearchNotifier] Location error: $e');
    }

    state = state.copyWith(latitude: latitude, longitude: longitude);

    debugPrint('[SearchNotifier] Filter: sortBy=${state.sortBy}, lat=$latitude, lng=$longitude');

    final filter = BeautyShopFilter(
      keyword: state.query.isEmpty ? null : state.query,
      sortBy: state.sortBy,
      sortOrder: state.sortBy == 'DISTANCE' ? 'ASC' : state.sortOrder,
      categoryId: state.categoryId,
      minRating: state.minRating,
      latitude: latitude,
      longitude: longitude,
      page: 0,
    );

    final result = await _getFilteredShopsUseCase(filter);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedShops) {
        state = state.copyWith(
          isLoading: false,
          results: pagedShops.items,
          hasMore: pagedShops.hasNext,
        );
      },
    );
  }
}

final manageSearchHistoryUseCaseProvider = Provider<ManageSearchHistoryUseCase>(
  (ref) {
    return sl<ManageSearchHistoryUseCase>();
  },
);

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
      return SearchNotifier(
        getFilteredShopsUseCase: ref.watch(getFilteredShopsUseCaseProvider),
        manageSearchHistoryUseCase: ref.watch(
          manageSearchHistoryUseCaseProvider,
        ),
      );
    });
