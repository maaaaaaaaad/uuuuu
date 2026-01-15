import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
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
  });

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
    String? sortBy,
    String? sortOrder,
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
      categoryId: categoryId ?? this.categoryId,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
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

    final filter = BeautyShopFilter(
      keyword: query,
      sortBy: state.sortBy,
      sortOrder: state.sortOrder,
      categoryId: state.categoryId,
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
    if (!state.hasMore || state.isLoadingMore || state.query.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final filter = BeautyShopFilter(
      keyword: state.query,
      sortBy: state.sortBy,
      sortOrder: state.sortOrder,
      categoryId: state.categoryId,
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
    state = state.copyWith(categoryId: categoryId);
  }

  void setSort(String sortBy, String sortOrder) {
    state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);
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
