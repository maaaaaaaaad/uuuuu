import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/external_shop/data/datasources/external_shop_remote_datasource.dart';
import 'package:jellomark/features/external_shop/domain/entities/external_shop.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';

class NearbyShopsMapState {
  final List<BeautyShop> shops;
  final List<ExternalShop> externalShops;
  final bool isLoading;
  final String? error;
  final BeautyShop? selectedShop;
  final ExternalShop? selectedExternalShop;
  final Set<String> favoriteShopIds;

  const NearbyShopsMapState({
    this.shops = const [],
    this.externalShops = const [],
    this.isLoading = false,
    this.error,
    this.selectedShop,
    this.selectedExternalShop,
    this.favoriteShopIds = const {},
  });

  NearbyShopsMapState copyWith({
    List<BeautyShop>? shops,
    List<ExternalShop>? externalShops,
    bool? isLoading,
    String? error,
    BeautyShop? selectedShop,
    ExternalShop? selectedExternalShop,
    bool clearSelectedShop = false,
    bool clearSelectedExternalShop = false,
    Set<String>? favoriteShopIds,
  }) {
    return NearbyShopsMapState(
      shops: shops ?? this.shops,
      externalShops: externalShops ?? this.externalShops,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedShop: clearSelectedShop ? null : (selectedShop ?? this.selectedShop),
      selectedExternalShop: clearSelectedExternalShop
          ? null
          : (selectedExternalShop ?? this.selectedExternalShop),
      favoriteShopIds: favoriteShopIds ?? this.favoriteShopIds,
    );
  }
}

class NearbyShopsMapNotifier extends StateNotifier<NearbyShopsMapState> {
  final GetFilteredShopsUseCase _getFilteredShopsUseCase;
  final ExternalShopRemoteDataSource? _externalShopDataSource;

  NearbyShopsMapNotifier(this._getFilteredShopsUseCase, this._externalShopDataSource)
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

    _loadExternalShops(latitude, longitude, radiusKm);
  }

  Future<void> _loadExternalShops(double latitude, double longitude, double radiusKm) async {
    if (_externalShopDataSource == null) return;

    try {
      final externalShops = await _externalShopDataSource.getNearbyExternalShops(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      state = state.copyWith(externalShops: externalShops);
    } catch (e) {
      // External shops are non-critical, don't show error
    }
  }

  void selectShop(BeautyShop shop) {
    state = state.copyWith(
      selectedShop: shop,
      clearSelectedExternalShop: true,
    );
  }

  void selectExternalShop(ExternalShop shop) {
    state = state.copyWith(
      selectedExternalShop: shop,
      clearSelectedShop: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      clearSelectedShop: true,
      clearSelectedExternalShop: true,
    );
  }

  void updateFavorites(Set<String> favoriteIds) {
    state = state.copyWith(favoriteShopIds: favoriteIds);
  }
}

final nearbyShopsMapProvider =
    StateNotifierProvider.autoDispose<NearbyShopsMapNotifier, NearbyShopsMapState>(
  (ref) {
    final useCase = sl<GetFilteredShopsUseCase>();
    ExternalShopRemoteDataSource? externalDataSource;
    try {
      externalDataSource = sl<ExternalShopRemoteDataSource>();
    } catch (_) {}

    final notifier = NearbyShopsMapNotifier(useCase, externalDataSource);

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
