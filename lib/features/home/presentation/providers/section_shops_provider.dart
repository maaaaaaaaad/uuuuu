import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/domain/entities/home_section.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/utils/distance_calculator.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';

class SectionShopsState extends Equatable {
  final List<BeautyShop> shops;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final ShopSortOption sort;
  final String? error;
  final UserLocation? userLocation;
  final int generation;

  const SectionShopsState({
    required this.sort,
    this.shops = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
    this.userLocation,
    this.generation = 0,
  });

  SectionShopsState copyWith({
    List<BeautyShop>? shops,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    ShopSortOption? sort,
    String? error,
    UserLocation? userLocation,
    int? generation,
  }) {
    return SectionShopsState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      sort: sort ?? this.sort,
      error: error,
      userLocation: userLocation ?? this.userLocation,
      generation: generation ?? this.generation,
    );
  }

  @override
  List<Object?> get props => [
    shops,
    isLoading,
    isLoadingMore,
    hasMore,
    page,
    sort,
    error,
    userLocation,
    generation,
  ];
}

class SectionShopsNotifier extends StateNotifier<SectionShopsState> {
  final HomeSection section;
  final GetFilteredShopsUseCase _useCase;
  final Future<UserLocation?> Function() _getCurrentLocation;

  static const int pageSize = 20;

  SectionShopsNotifier({
    required this.section,
    required GetFilteredShopsUseCase useCase,
    required Future<UserLocation?> Function() getCurrentLocation,
  }) : _useCase = useCase,
       _getCurrentLocation = getCurrentLocation,
       super(SectionShopsState(sort: section.defaultSort));

  Future<void> loadInitial() => _loadFirstPage();

  Future<void> changeSort(ShopSortOption sort) {
    if (sort == state.sort) return Future.value();
    state = state.copyWith(sort: sort);
    return _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final generation = state.generation + 1;
    state = state.copyWith(
      generation: generation,
      isLoading: true,
      isLoadingMore: false,
      error: null,
      shops: const [],
      page: 0,
      hasMore: true,
    );

    final location = await _getCurrentLocation();
    if (generation != state.generation) return;

    final result = await _useCase(_buildFilter(0, state.sort, location));
    if (generation != state.generation) return;

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (paged) => state = state.copyWith(
        shops: _withDistance(paged.items, location),
        hasMore: paged.hasNext,
        page: 0,
        isLoading: false,
        userLocation: location,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    final generation = state.generation;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final result = await _useCase(
      _buildFilter(nextPage, state.sort, state.userLocation),
    );
    if (generation != state.generation) return;

    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingMore: false, error: failure.message),
      (paged) => state = state.copyWith(
        shops: [
          ...state.shops,
          ..._withDistance(paged.items, state.userLocation),
        ],
        hasMore: paged.hasNext,
        page: nextPage,
        isLoadingMore: false,
      ),
    );
  }

  BeautyShopFilter _buildFilter(
    int page,
    ShopSortOption sort,
    UserLocation? location,
  ) {
    return BeautyShopFilter(
      sortBy: sort.sortBy,
      sortOrder: sort.sortOrder,
      size: pageSize,
      page: page,
      minRating: section.minRating,
      latitude: sort.requiresLocation ? location?.latitude : null,
      longitude: sort.requiresLocation ? location?.longitude : null,
    );
  }

  List<BeautyShop> _withDistance(
    List<BeautyShop> shops,
    UserLocation? location,
  ) {
    if (location == null) return shops;

    return shops.map((shop) {
      if (shop.latitude == null || shop.longitude == null) return shop;
      final distance = calculateDistanceKm(
        location.latitude,
        location.longitude,
        shop.latitude!,
        shop.longitude!,
      );
      return shop.copyWith(distance: distance);
    }).toList();
  }
}

final sectionShopsNotifierProvider = StateNotifierProvider.autoDispose
    .family<SectionShopsNotifier, SectionShopsState, HomeSection>(
      (ref, section) => SectionShopsNotifier(
        section: section,
        useCase: ref.watch(getFilteredShopsUseCaseProvider),
        getCurrentLocation: () => ref.read(currentLocationProvider.future),
      ),
    );
