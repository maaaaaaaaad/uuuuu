import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/presentation/providers/recent_shops_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRecentShopsUseCase extends Mock implements GetRecentShopsUseCase {}

class MockAddRecentShopUseCase extends Mock implements AddRecentShopUseCase {}

class MockClearRecentShopsUseCase extends Mock
    implements ClearRecentShopsUseCase {}

class FakeRecentShop extends Fake implements RecentShop {}

void main() {
  late MockGetRecentShopsUseCase mockGetRecentShopsUseCase;
  late MockAddRecentShopUseCase mockAddRecentShopUseCase;
  late MockClearRecentShopsUseCase mockClearRecentShopsUseCase;

  setUpAll(() {
    registerFallbackValue(FakeRecentShop());
  });

  setUp(() {
    mockGetRecentShopsUseCase = MockGetRecentShopsUseCase();
    mockAddRecentShopUseCase = MockAddRecentShopUseCase();
    mockClearRecentShopsUseCase = MockClearRecentShopsUseCase();
  });

  group('RecentShopsNotifier - Distance Calculation', () {
    test(
        'loadRecentShops calculates distance when user location is available',
        () async {
      const userLocation =
          UserLocation(latitude: 37.5172, longitude: 127.0473);

      final shopsFromStorage = [
        RecentShop(
          shopId: 'shop1',
          shopName: 'Near Shop',
          latitude: 37.5180,
          longitude: 127.0480,
          viewedAt: DateTime(2024, 1, 1),
        ),
        RecentShop(
          shopId: 'shop2',
          shopName: 'Far Shop',
          latitude: 37.5547,
          longitude: 126.9707,
          viewedAt: DateTime(2024, 1, 2),
        ),
      ];

      when(() => mockGetRecentShopsUseCase()).thenAnswer(
        (_) async => Right(shopsFromStorage),
      );

      final container = ProviderContainer(
        overrides: [
          getRecentShopsUseCaseProvider
              .overrideWithValue(mockGetRecentShopsUseCase),
          addRecentShopUseCaseProvider
              .overrideWithValue(mockAddRecentShopUseCase),
          clearRecentShopsUseCaseProvider
              .overrideWithValue(mockClearRecentShopsUseCase),
          currentLocationProvider.overrideWith((ref) async => userLocation),
        ],
      );

      final notifier = container.read(recentShopsNotifierProvider.notifier);
      await notifier.loadRecentShops();

      final state = container.read(recentShopsNotifierProvider);
      expect(state.items.length, 2);

      for (final shop in state.items) {
        expect(shop.distance, isNotNull);
        expect(shop.distance, greaterThan(0));
      }

      container.dispose();
    });

    test('loadRecentShops returns shops without distance when location is null',
        () async {
      final shopsFromStorage = [
        RecentShop(
          shopId: 'shop1',
          shopName: 'Shop',
          latitude: 37.5180,
          longitude: 127.0480,
          viewedAt: DateTime(2024, 1, 1),
        ),
      ];

      when(() => mockGetRecentShopsUseCase()).thenAnswer(
        (_) async => Right(shopsFromStorage),
      );

      final container = ProviderContainer(
        overrides: [
          getRecentShopsUseCaseProvider
              .overrideWithValue(mockGetRecentShopsUseCase),
          addRecentShopUseCaseProvider
              .overrideWithValue(mockAddRecentShopUseCase),
          clearRecentShopsUseCaseProvider
              .overrideWithValue(mockClearRecentShopsUseCase),
          currentLocationProvider.overrideWith((ref) async => null),
        ],
      );

      final notifier = container.read(recentShopsNotifierProvider.notifier);
      await notifier.loadRecentShops();

      final state = container.read(recentShopsNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items[0].distance, isNull);

      container.dispose();
    });
  });
}
