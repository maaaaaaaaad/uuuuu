import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';
import 'package:jellomark/features/favorite/domain/usecases/add_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/remove_favorite_usecase.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

class MockAddFavoriteUseCase extends Mock implements AddFavoriteUseCase {}

class MockRemoveFavoriteUseCase extends Mock implements RemoveFavoriteUseCase {}

class FakeGetFavoritesParams extends Fake implements GetFavoritesParams {}

void main() {
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;
  late MockAddFavoriteUseCase mockAddFavoriteUseCase;
  late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;

  setUpAll(() {
    registerFallbackValue(FakeGetFavoritesParams());
  });

  setUp(() {
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    mockAddFavoriteUseCase = MockAddFavoriteUseCase();
    mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();
  });

  group('FavoritesNotifier - Distance Calculation', () {
    test('loadFavorites calculates distance when user location is available',
        () async {
      const userLocation =
          UserLocation(latitude: 37.5172, longitude: 127.0473);

      final favoritesFromApi = [
        FavoriteShop(
          id: 'fav1',
          shopId: 'shop1',
          createdAt: DateTime(2024, 1, 1),
          shop: const BeautyShop(
            id: 'shop1',
            name: 'Near Shop',
            address: 'Address',
            latitude: 37.5180,
            longitude: 127.0480,
          ),
        ),
        FavoriteShop(
          id: 'fav2',
          shopId: 'shop2',
          createdAt: DateTime(2024, 1, 2),
          shop: const BeautyShop(
            id: 'shop2',
            name: 'Far Shop',
            address: 'Address',
            latitude: 37.5547,
            longitude: 126.9707,
          ),
        ),
      ];

      when(() => mockGetFavoritesUseCase(any())).thenAnswer(
        (_) async => Right(
          PagedFavorites(
            items: favoritesFromApi,
            hasNext: false,
            totalElements: 2,
            totalPages: 1,
            page: 0,
            size: 20,
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFavoritesUseCaseProvider
              .overrideWithValue(mockGetFavoritesUseCase),
          addFavoriteUseCaseProvider.overrideWithValue(mockAddFavoriteUseCase),
          removeFavoriteUseCaseProvider
              .overrideWithValue(mockRemoveFavoriteUseCase),
          currentLocationProvider.overrideWith((ref) async => userLocation),
        ],
      );

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.loadFavorites();

      final state = container.read(favoritesNotifierProvider);
      expect(state.items.length, 2);

      for (final favorite in state.items) {
        expect(favorite.shop, isNotNull);
        expect(favorite.shop!.distance, isNotNull);
        expect(favorite.shop!.distance, greaterThan(0));
      }

      container.dispose();
    });

    test('loadFavorites returns shops without distance when location is null',
        () async {
      final favoritesFromApi = [
        FavoriteShop(
          id: 'fav1',
          shopId: 'shop1',
          createdAt: DateTime(2024, 1, 1),
          shop: const BeautyShop(
            id: 'shop1',
            name: 'Shop',
            address: 'Address',
            latitude: 37.5180,
            longitude: 127.0480,
          ),
        ),
      ];

      when(() => mockGetFavoritesUseCase(any())).thenAnswer(
        (_) async => Right(
          PagedFavorites(
            items: favoritesFromApi,
            hasNext: false,
            totalElements: 1,
            totalPages: 1,
            page: 0,
            size: 20,
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFavoritesUseCaseProvider
              .overrideWithValue(mockGetFavoritesUseCase),
          addFavoriteUseCaseProvider.overrideWithValue(mockAddFavoriteUseCase),
          removeFavoriteUseCaseProvider
              .overrideWithValue(mockRemoveFavoriteUseCase),
          currentLocationProvider.overrideWith((ref) async => null),
        ],
      );

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.loadFavorites();

      final state = container.read(favoritesNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items[0].shop!.distance, isNull);

      container.dispose();
    });

    test('loadMore calculates distance using stored user location', () async {
      const userLocation =
          UserLocation(latitude: 37.5172, longitude: 127.0473);

      final initialFavorites = [
        FavoriteShop(
          id: 'fav1',
          shopId: 'shop1',
          createdAt: DateTime(2024, 1, 1),
          shop: const BeautyShop(
            id: 'shop1',
            name: 'Shop1',
            address: 'Address',
            latitude: 37.5180,
            longitude: 127.0480,
          ),
        ),
      ];

      final moreFavorites = [
        FavoriteShop(
          id: 'fav2',
          shopId: 'shop2',
          createdAt: DateTime(2024, 1, 2),
          shop: const BeautyShop(
            id: 'shop2',
            name: 'Shop2',
            address: 'Address',
            latitude: 37.5200,
            longitude: 127.0500,
          ),
        ),
      ];

      int callCount = 0;
      when(() => mockGetFavoritesUseCase(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Right(
            PagedFavorites(
              items: initialFavorites,
              hasNext: true,
              totalElements: 2,
              totalPages: 2,
              page: 0,
              size: 20,
            ),
          );
        }
        return Right(
          PagedFavorites(
            items: moreFavorites,
            hasNext: false,
            totalElements: 2,
            totalPages: 2,
            page: 1,
            size: 20,
          ),
        );
      });

      final container = ProviderContainer(
        overrides: [
          getFavoritesUseCaseProvider
              .overrideWithValue(mockGetFavoritesUseCase),
          addFavoriteUseCaseProvider.overrideWithValue(mockAddFavoriteUseCase),
          removeFavoriteUseCaseProvider
              .overrideWithValue(mockRemoveFavoriteUseCase),
          currentLocationProvider.overrideWith((ref) async => userLocation),
        ],
      );

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.loadFavorites();
      await notifier.loadMore();

      final state = container.read(favoritesNotifierProvider);
      expect(state.items.length, 2);

      for (final favorite in state.items) {
        expect(favorite.shop, isNotNull);
        expect(favorite.shop!.distance, isNotNull);
        expect(favorite.shop!.distance, greaterThan(0));
      }

      container.dispose();
    });
  });
}
