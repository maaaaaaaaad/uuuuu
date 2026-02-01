import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';

class NearbyShopsMapState {
  final List<BeautyShop> shops;
  final bool isLoading;
  final String? error;
  final BeautyShop? selectedShop;
  final Set<String> favoriteShopIds;

  const NearbyShopsMapState({
    this.shops = const [],
    this.isLoading = false,
    this.error,
    this.selectedShop,
    this.favoriteShopIds = const {},
  });

  NearbyShopsMapState copyWith({
    List<BeautyShop>? shops,
    bool? isLoading,
    String? error,
    BeautyShop? selectedShop,
    bool clearSelectedShop = false,
    Set<String>? favoriteShopIds,
  }) {
    return NearbyShopsMapState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedShop: clearSelectedShop ? null : (selectedShop ?? this.selectedShop),
      favoriteShopIds: favoriteShopIds ?? this.favoriteShopIds,
    );
  }
}

class NearbyShopsMapNotifier extends StateNotifier<NearbyShopsMapState> {
  final GetFilteredShopsUseCase _getFilteredShopsUseCase;

  NearbyShopsMapNotifier(this._getFilteredShopsUseCase)
      : super(const NearbyShopsMapState());

  Future<void> loadShops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final filter = BeautyShopFilter(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      sortBy: 'DISTANCE',
      sortOrder: 'ASC',
      size: 100,
    );

    final result = await _getFilteredShopsUseCase(filter);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (pagedShops) {
        final shopsWithLocation = pagedShops.items.where(
          (shop) => shop.latitude != null && shop.longitude != null,
        ).toList();

        state = state.copyWith(
          isLoading: false,
          shops: shopsWithLocation,
        );
      },
    );
  }

  void selectShop(BeautyShop shop) {
    state = state.copyWith(selectedShop: shop);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedShop: true);
  }

  void updateFavorites(Set<String> favoriteIds) {
    state = state.copyWith(favoriteShopIds: favoriteIds);
  }
}

final nearbyShopsMapProvider =
    StateNotifierProvider.autoDispose<NearbyShopsMapNotifier, NearbyShopsMapState>(
  (ref) {
    final useCase = sl<GetFilteredShopsUseCase>();
    final notifier = NearbyShopsMapNotifier(useCase);

    final location = ref.watch(currentLocationProvider).valueOrNull;
    if (location != null) {
      notifier.loadShops(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    }

    final favoritesState = ref.watch(favoritesNotifierProvider);
    final favoriteIds = favoritesState.items.map((f) => f.shopId).toSet();
    notifier.updateFavorites(favoriteIds);

    return notifier;
  },
);
