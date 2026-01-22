import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';

class RecentShopsState extends Equatable {
  final List<RecentShop> items;
  final bool isLoading;
  final String? error;

  const RecentShopsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  RecentShopsState copyWith({
    List<RecentShop>? items,
    bool? isLoading,
    String? error,
  }) {
    return RecentShopsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error];
}

class RecentShopsNotifier extends StateNotifier<RecentShopsState> {
  final GetRecentShopsUseCase _getRecentShopsUseCase;
  final AddRecentShopUseCase _addRecentShopUseCase;
  final ClearRecentShopsUseCase _clearRecentShopsUseCase;

  RecentShopsNotifier({
    required GetRecentShopsUseCase getRecentShopsUseCase,
    required AddRecentShopUseCase addRecentShopUseCase,
    required ClearRecentShopsUseCase clearRecentShopsUseCase,
  })  : _getRecentShopsUseCase = getRecentShopsUseCase,
        _addRecentShopUseCase = addRecentShopUseCase,
        _clearRecentShopsUseCase = clearRecentShopsUseCase,
        super(const RecentShopsState());

  Future<void> loadRecentShops() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getRecentShopsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (shops) {
        state = state.copyWith(isLoading: false, items: shops);
      },
    );
  }

  Future<void> addRecentShop(RecentShop shop) async {
    await _addRecentShopUseCase(shop);
    await loadRecentShops();
  }

  Future<void> clearRecentShops() async {
    final result = await _clearRecentShopsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        state = state.copyWith(items: []);
      },
    );
  }
}

final getRecentShopsUseCaseProvider = Provider<GetRecentShopsUseCase>(
  (ref) => sl<GetRecentShopsUseCase>(),
);

final addRecentShopUseCaseProvider = Provider<AddRecentShopUseCase>(
  (ref) => sl<AddRecentShopUseCase>(),
);

final clearRecentShopsUseCaseProvider = Provider<ClearRecentShopsUseCase>(
  (ref) => sl<ClearRecentShopsUseCase>(),
);

final recentShopsNotifierProvider =
    StateNotifierProvider<RecentShopsNotifier, RecentShopsState>((ref) {
  return RecentShopsNotifier(
    getRecentShopsUseCase: ref.watch(getRecentShopsUseCaseProvider),
    addRecentShopUseCase: ref.watch(addRecentShopUseCaseProvider),
    clearRecentShopsUseCase: ref.watch(clearRecentShopsUseCaseProvider),
  );
});
