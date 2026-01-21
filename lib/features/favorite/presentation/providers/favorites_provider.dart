import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';
import 'package:jellomark/features/favorite/domain/usecases/add_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/check_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/remove_favorite_usecase.dart';

class FavoritesState extends Equatable {
  final List<FavoriteShop> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;

  const FavoritesState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 0,
    this.isLoadingMore = false,
  });

  FavoritesState copyWith({
    List<FavoriteShop>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [items, isLoading, error, hasMore, page, isLoadingMore];
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  FavoritesNotifier({
    required GetFavoritesUseCase getFavoritesUseCase,
    required AddFavoriteUseCase addFavoriteUseCase,
    required RemoveFavoriteUseCase removeFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _addFavoriteUseCase = addFavoriteUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase,
        super(const FavoritesState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null, page: 0, items: []);

    final result = await _getFavoritesUseCase(const GetFavoritesParams(page: 0));
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pagedFavorites) {
        state = state.copyWith(
          isLoading: false,
          items: pagedFavorites.items,
          hasMore: pagedFavorites.hasNext,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final result = await _getFavoritesUseCase(GetFavoritesParams(page: nextPage));
    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure.message);
      },
      (pagedFavorites) {
        state = state.copyWith(
          isLoadingMore: false,
          items: [...state.items, ...pagedFavorites.items],
          hasMore: pagedFavorites.hasNext,
          page: nextPage,
        );
      },
    );
  }

  Future<void> addFavorite(String shopId) async {
    final result = await _addFavoriteUseCase(shopId);
    result.fold(
      (failure) {},
      (favorite) {
        state = state.copyWith(items: [favorite, ...state.items]);
      },
    );
  }

  Future<void> removeFavorite(String shopId) async {
    final result = await _removeFavoriteUseCase(shopId);
    result.fold(
      (failure) {},
      (_) {
        state = state.copyWith(
          items: state.items.where((item) => item.shopId != shopId).toList(),
        );
      },
    );
  }
}

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>(
  (ref) => sl<GetFavoritesUseCase>(),
);

final addFavoriteUseCaseProvider = Provider<AddFavoriteUseCase>(
  (ref) => sl<AddFavoriteUseCase>(),
);

final removeFavoriteUseCaseProvider = Provider<RemoveFavoriteUseCase>(
  (ref) => sl<RemoveFavoriteUseCase>(),
);

final checkFavoriteUseCaseProvider = Provider<CheckFavoriteUseCase>(
  (ref) => sl<CheckFavoriteUseCase>(),
);

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(
    getFavoritesUseCase: ref.watch(getFavoritesUseCaseProvider),
    addFavoriteUseCase: ref.watch(addFavoriteUseCaseProvider),
    removeFavoriteUseCase: ref.watch(removeFavoriteUseCaseProvider),
  );
});

final favoriteStatusProvider =
    FutureProvider.family<bool, String>((ref, shopId) async {
  final checkUseCase = ref.watch(checkFavoriteUseCaseProvider);
  final result = await checkUseCase(shopId);
  return result.fold((failure) => false, (isFavorite) => isFavorite);
});
