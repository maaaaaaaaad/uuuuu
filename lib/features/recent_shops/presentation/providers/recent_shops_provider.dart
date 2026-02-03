import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/utils/distance_calculator.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';

class RecentShopsState extends Equatable {
  final List<RecentShop> items;
  final bool isLoading;
  final String? error;
  final UserLocation? userLocation;

  const RecentShopsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.userLocation,
  });

  RecentShopsState copyWith({
    List<RecentShop>? items,
    bool? isLoading,
    String? error,
    UserLocation? userLocation,
  }) {
    return RecentShopsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error, userLocation];
}

class RecentShopsNotifier extends StateNotifier<RecentShopsState> {
  final GetRecentShopsUseCase _getRecentShopsUseCase;
  final AddRecentShopUseCase _addRecentShopUseCase;
  final ClearRecentShopsUseCase _clearRecentShopsUseCase;
  final Future<UserLocation?> Function() _getCurrentLocation;

  RecentShopsNotifier({
    required GetRecentShopsUseCase getRecentShopsUseCase,
    required AddRecentShopUseCase addRecentShopUseCase,
    required ClearRecentShopsUseCase clearRecentShopsUseCase,
    required Future<UserLocation?> Function() getCurrentLocation,
  })  : _getRecentShopsUseCase = getRecentShopsUseCase,
        _addRecentShopUseCase = addRecentShopUseCase,
        _clearRecentShopsUseCase = clearRecentShopsUseCase,
        _getCurrentLocation = getCurrentLocation,
        super(const RecentShopsState());

  Future<void> loadRecentShops() async {
    state = state.copyWith(isLoading: true, error: null);

    final userLocation = await _getCurrentLocation();
    state = state.copyWith(userLocation: userLocation);

    final result = await _getRecentShopsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (shops) {
        final shopsWithDistance = _addDistanceToShops(shops, userLocation);
        state = state.copyWith(isLoading: false, items: shopsWithDistance);
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

  List<RecentShop> _addDistanceToShops(
    List<RecentShop> shops,
    UserLocation? userLocation,
  ) {
    if (userLocation == null) {
      return shops;
    }

    return shops.map((shop) {
      if (shop.latitude == null || shop.longitude == null) {
        return shop;
      }

      final distance = calculateDistanceKm(
        userLocation.latitude,
        userLocation.longitude,
        shop.latitude!,
        shop.longitude!,
      );

      return shop.copyWith(distance: distance);
    }).toList();
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
    getCurrentLocation: () => ref.read(currentLocationProvider.future),
  );
});
