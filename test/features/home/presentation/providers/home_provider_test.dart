import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

void main() {
  late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;

  setUpAll(() {
    registerFallbackValue(FakeBeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
  });

  group('HomeState', () {
    test('initial state has correct default values', () {
      const state = HomeState();

      expect(state.recommendedShops, isEmpty);
      expect(state.newShops, isEmpty);
      expect(state.nearbyShops, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.newShopsPage, 0);
      expect(state.hasMoreRecommended, isFalse);
      expect(state.hasMoreNewShops, isTrue);
      expect(state.isLoadingMoreNewShops, isFalse);
    });

    test('copyWith creates a new state with updated values', () {
      const state = HomeState();
      const shops = [BeautyShop(id: '1', name: 'Shop', address: 'Address')];
      const nearbyShops = [
        BeautyShop(id: '2', name: 'Nearby', address: 'Nearby Address'),
      ];
      const categories = [Category(id: '1', name: 'Category')];

      final newState = state.copyWith(
        recommendedShops: shops,
        nearbyShops: nearbyShops,
        categories: categories,
        isLoading: true,
        error: 'Error',
      );

      expect(newState.recommendedShops, shops);
      expect(newState.nearbyShops, nearbyShops);
      expect(newState.categories, categories);
      expect(newState.isLoading, isTrue);
      expect(newState.error, 'Error');
    });

    test('copyWith preserves values when not provided', () {
      const shops = [BeautyShop(id: '1', name: 'Shop', address: 'Address')];
      const state = HomeState(recommendedShops: shops, isLoading: true);

      final newState = state.copyWith(error: 'Error');

      expect(newState.recommendedShops, shops);
      expect(newState.isLoading, isTrue);
      expect(newState.error, 'Error');
    });

    test('displayedRecommendedShops returns limited shops', () {
      final shops = List.generate(
        10,
        (i) => BeautyShop(id: '$i', name: 'Shop$i', address: 'Addr'),
      );
      final state = HomeState(recommendedShops: shops);

      expect(
        state.displayedRecommendedShops.length,
        HomeState.recommendedDisplayLimit,
      );
    });
  });

  group('HomeNotifier', () {
    test(
      'loadData fetches categories and shops including nearbyShops',
      () async {
        const categories = [
          Category(id: '1', name: 'Nail'),
          Category(id: '2', name: 'Lash'),
        ];
        const recommendedShops = [
          BeautyShop(id: '1', name: 'Recommended', address: 'Address'),
        ];
        const newShops = [
          BeautyShop(
            id: '2',
            name: 'New Shop',
            address: 'Address',
            isNew: true,
          ),
        ];
        const nearbyShops = [
          BeautyShop(
            id: '3',
            name: 'Popular Nearby',
            address: 'Address',
            rating: 4.8,
          ),
        ];

        when(
          () => mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const Right(categories));

        when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
          invocation,
        ) async {
          final filter = invocation.positionalArguments[0] as BeautyShopFilter;
          if (filter.sortBy == 'RATING' && filter.minRating == 4.0) {
            return const Right(
              PagedBeautyShops(
                items: nearbyShops,
                hasNext: false,
                totalElements: 1,
              ),
            );
          } else if (filter.sortBy == 'RATING') {
            return const Right(
              PagedBeautyShops(
                items: recommendedShops,
                hasNext: false,
                totalElements: 1,
              ),
            );
          } else if (filter.sortBy == 'CREATED_AT') {
            return const Right(
              PagedBeautyShops(
                items: newShops,
                hasNext: false,
                totalElements: 1,
              ),
            );
          }
          return const Right(
            PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
          );
        });

        final container = ProviderContainer(
          overrides: [
            getFilteredShopsUseCaseProvider.overrideWithValue(
              mockGetFilteredShopsUseCase,
            ),
            getCategoriesUseCaseProvider.overrideWithValue(
              mockGetCategoriesUseCase,
            ),
            currentLocationProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );

        final notifier = container.read(homeNotifierProvider.notifier);
        await notifier.loadData();

        final state = container.read(homeNotifierProvider);
        expect(state.categories, categories);
        expect(state.recommendedShops, recommendedShops);
        expect(state.nearbyShops, nearbyShops);
        expect(state.newShops, newShops);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      },
    );

    test('loadData sets isLoading to true while loading', () async {
      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      final future = notifier.loadData();

      expect(container.read(homeNotifierProvider).isLoading, isTrue);

      await future;

      expect(container.read(homeNotifierProvider).isLoading, isFalse);
    });

    test('loadData continues when category fetch fails', () async {
      const testShops = [
        BeautyShop(id: '1', name: 'Test Shop', address: 'Seoul'),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Left(ServerFailure('Network error')));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: testShops, hasNext: false, totalElements: 1),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      final state = container.read(homeNotifierProvider);
      expect(state.categories, isEmpty);
      expect(state.recommendedShops, isNotEmpty);
      expect(state.isLoading, isFalse);
    });

    test('loadData continues when one shops fetch fails', () async {
      const testShops = [
        BeautyShop(id: '1', name: 'Test Shop', address: 'Seoul'),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.minRating == 4.0) {
          return const Left(ServerFailure('Server error'));
        }
        return const Right(
          PagedBeautyShops(items: testShops, hasNext: false, totalElements: 1),
        );
      });

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      final state = container.read(homeNotifierProvider);
      expect(state.nearbyShops, isEmpty);
      expect(state.recommendedShops, isNotEmpty);
      expect(state.newShops, isNotEmpty);
      expect(state.isLoading, isFalse);
    });

    test('refresh clears error and reloads data', () async {
      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.refresh();

      verify(() => mockGetCategoriesUseCase()).called(1);
      verify(() => mockGetFilteredShopsUseCase(any())).called(3);
    });

    test('loadData sets hasMoreRecommended based on item count', () async {
      final manyShops = List.generate(
        HomeState.recommendedDisplayLimit + 1,
        (i) => BeautyShop(id: '$i', name: 'Shop$i', address: 'Addr'),
      );

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'RATING' && filter.minRating == null) {
          return Right(
            PagedBeautyShops(
              items: manyShops,
              hasNext: false,
              totalElements: manyShops.length,
            ),
          );
        }
        return const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      final state = container.read(homeNotifierProvider);
      expect(state.hasMoreRecommended, isTrue);
    });

    test('loadMoreNewShops appends shops and increments page', () async {
      const initialShops = [
        BeautyShop(id: '1', name: 'New1', address: 'Addr', isNew: true),
      ];
      const moreShops = [
        BeautyShop(id: '2', name: 'New2', address: 'Addr', isNew: true),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));

      int newShopsCallCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'CREATED_AT') {
          newShopsCallCount++;
          if (newShopsCallCount == 1) {
            return const Right(
              PagedBeautyShops(
                items: initialShops,
                hasNext: true,
                totalElements: 10,
              ),
            );
          } else {
            return const Right(
              PagedBeautyShops(
                items: moreShops,
                hasNext: false,
                totalElements: 10,
              ),
            );
          }
        }
        return const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      var state = container.read(homeNotifierProvider);
      expect(state.newShops, initialShops);
      expect(state.newShopsPage, 0);
      expect(state.hasMoreNewShops, isTrue);

      await notifier.loadMoreNewShops();

      state = container.read(homeNotifierProvider);
      expect(state.newShops.length, 2);
      expect(state.newShops, [...initialShops, ...moreShops]);
      expect(state.newShopsPage, 1);
      expect(state.hasMoreNewShops, isFalse);
    });

    test('loadMoreNewShops does not load if hasMore is false', () async {
      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      clearInteractions(mockGetFilteredShopsUseCase);

      await notifier.loadMoreNewShops();

      verifyNever(() => mockGetFilteredShopsUseCase(any()));
    });

    test(
      'loadMoreNewShops sets isLoadingMoreNewShops during load',
      () async {
        when(
          () => mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const Right([]));

        int callCount = 0;
        when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
          invocation,
        ) async {
          final filter = invocation.positionalArguments[0] as BeautyShopFilter;
          if (filter.sortBy == 'CREATED_AT') {
            callCount++;
            if (callCount == 1) {
              return const Right(
                PagedBeautyShops(
                  items: [BeautyShop(id: '1', name: 'Shop', address: 'Addr')],
                  hasNext: true,
                  totalElements: 10,
                ),
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 50));
              return const Right(
                PagedBeautyShops(items: [], hasNext: false, totalElements: 10),
              );
            }
          }
          return const Right(
            PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
          );
        });

        final container = ProviderContainer(
          overrides: [
            getFilteredShopsUseCaseProvider.overrideWithValue(
              mockGetFilteredShopsUseCase,
            ),
            getCategoriesUseCaseProvider.overrideWithValue(
              mockGetCategoriesUseCase,
            ),
            currentLocationProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );

        final notifier = container.read(homeNotifierProvider.notifier);
        await notifier.loadData();

        final future = notifier.loadMoreNewShops();

        expect(
          container.read(homeNotifierProvider).isLoadingMoreNewShops,
          isTrue,
        );

        await future;

        expect(
          container.read(homeNotifierProvider).isLoadingMoreNewShops,
          isFalse,
        );
      },
    );

    test('refresh resets pagination state', () async {
      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));

      int callCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'CREATED_AT') {
          callCount++;
          if (callCount == 1) {
            return const Right(
              PagedBeautyShops(
                items: [BeautyShop(id: '1', name: 'Shop', address: 'Addr')],
                hasNext: true,
                totalElements: 10,
              ),
            );
          } else if (callCount == 2) {
            return const Right(
              PagedBeautyShops(
                items: [BeautyShop(id: '2', name: 'Shop2', address: 'Addr')],
                hasNext: false,
                totalElements: 10,
              ),
            );
          } else {
            return const Right(
              PagedBeautyShops(
                items: [BeautyShop(id: '3', name: 'Fresh', address: 'Addr')],
                hasNext: true,
                totalElements: 10,
              ),
            );
          }
        }
        return const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });

      final container = ProviderContainer(
        overrides: [
          getFilteredShopsUseCaseProvider.overrideWithValue(
            mockGetFilteredShopsUseCase,
          ),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          currentLocationProvider.overrideWith(
            (ref) async => null,
          ),
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();
      await notifier.loadMoreNewShops();

      var state = container.read(homeNotifierProvider);
      expect(state.newShopsPage, 1);
      expect(state.hasMoreNewShops, isFalse);

      await notifier.refresh();

      state = container.read(homeNotifierProvider);
      expect(state.newShopsPage, 0);
      expect(state.hasMoreNewShops, isTrue);
    });

    test(
      'loadData calculates distance and sorts nearbyShops by distance then rating',
      () async {
        const userLocation = UserLocation(latitude: 37.5172, longitude: 127.0473);

        const nearbyShopsFromApi = [
          BeautyShop(
            id: '1',
            name: 'Far High Rating',
            address: 'Address',
            latitude: 37.5547,
            longitude: 126.9707,
            rating: 4.9,
          ),
          BeautyShop(
            id: '2',
            name: 'Near Low Rating',
            address: 'Address',
            latitude: 37.5182,
            longitude: 127.0483,
            rating: 4.0,
          ),
          BeautyShop(
            id: '3',
            name: 'Near High Rating',
            address: 'Address',
            latitude: 37.5180,
            longitude: 127.0480,
            rating: 4.8,
          ),
        ];

        when(
          () => mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const Right([]));

        when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
          invocation,
        ) async {
          final filter = invocation.positionalArguments[0] as BeautyShopFilter;
          if (filter.sortBy == 'RATING' && filter.minRating == 4.0) {
            return const Right(
              PagedBeautyShops(
                items: nearbyShopsFromApi,
                hasNext: false,
                totalElements: 3,
              ),
            );
          }
          return const Right(
            PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
          );
        });

        final container = ProviderContainer(
          overrides: [
            getFilteredShopsUseCaseProvider.overrideWithValue(
              mockGetFilteredShopsUseCase,
            ),
            getCategoriesUseCaseProvider.overrideWithValue(
              mockGetCategoriesUseCase,
            ),
            currentLocationProvider.overrideWith(
              (ref) async => userLocation,
            ),
          ],
        );

        final notifier = container.read(homeNotifierProvider.notifier);
        await notifier.loadData();

        final state = container.read(homeNotifierProvider);
        expect(state.nearbyShops.length, 3);

        expect(state.nearbyShops[0].name, 'Near High Rating');
        expect(state.nearbyShops[1].name, 'Near Low Rating');
        expect(state.nearbyShops[2].name, 'Far High Rating');

        for (final shop in state.nearbyShops) {
          expect(shop.distance, isNotNull);
          expect(shop.distance, greaterThan(0));
        }
      },
    );

    test(
      'loadData works without location when currentLocationProvider returns null',
      () async {
        const nearbyShopsFromApi = [
          BeautyShop(
            id: '1',
            name: 'Shop A',
            address: 'Address',
            latitude: 37.5547,
            longitude: 126.9707,
            rating: 4.5,
          ),
        ];

        when(
          () => mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const Right([]));

        when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
          invocation,
        ) async {
          final filter = invocation.positionalArguments[0] as BeautyShopFilter;
          if (filter.sortBy == 'RATING' && filter.minRating == 4.0) {
            return const Right(
              PagedBeautyShops(
                items: nearbyShopsFromApi,
                hasNext: false,
                totalElements: 1,
              ),
            );
          }
          return const Right(
            PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
          );
        });

        final container = ProviderContainer(
          overrides: [
            getFilteredShopsUseCaseProvider.overrideWithValue(
              mockGetFilteredShopsUseCase,
            ),
            getCategoriesUseCaseProvider.overrideWithValue(
              mockGetCategoriesUseCase,
            ),
            currentLocationProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );

        final notifier = container.read(homeNotifierProvider.notifier);
        await notifier.loadData();

        final state = container.read(homeNotifierProvider);
        expect(state.nearbyShops.length, 1);
        expect(state.nearbyShops[0].distance, isNull);
      },
    );
  });
}
