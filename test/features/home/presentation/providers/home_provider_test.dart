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
      expect(state.recommendedPage, 0);
      expect(state.newShopsPage, 0);
      expect(state.hasMoreRecommended, true);
      expect(state.hasMoreNewShops, true);
      expect(state.isLoadingMoreRecommended, isFalse);
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
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.refresh();

      verify(() => mockGetCategoriesUseCase()).called(1);
      verify(() => mockGetFilteredShopsUseCase(any())).called(3);
    });

    test('loadData sets hasMore based on backend response', () async {
      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'RATING' && filter.minRating == null) {
          return const Right(
            PagedBeautyShops(
              items: [BeautyShop(id: '1', name: 'Shop', address: 'Addr')],
              hasNext: true,
              totalElements: 100,
            ),
          );
        } else if (filter.sortBy == 'CREATED_AT') {
          return const Right(
            PagedBeautyShops(
              items: [BeautyShop(id: '2', name: 'New', address: 'Addr')],
              hasNext: true,
              totalElements: 50,
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
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      final state = container.read(homeNotifierProvider);
      expect(state.hasMoreRecommended, isTrue);
      expect(state.hasMoreNewShops, isTrue);
      expect(state.recommendedPage, 0);
      expect(state.newShopsPage, 0);
    });

    test('loadMoreRecommended appends shops and increments page', () async {
      const initialShops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Addr'),
      ];
      const moreShops = [BeautyShop(id: '2', name: 'Shop2', address: 'Addr')];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right([]));

      int recommendedCallCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'RATING' && filter.minRating == null) {
          recommendedCallCount++;
          if (recommendedCallCount == 1) {
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
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      var state = container.read(homeNotifierProvider);
      expect(state.recommendedShops, initialShops);
      expect(state.recommendedPage, 0);
      expect(state.hasMoreRecommended, isTrue);

      await notifier.loadMoreRecommended();

      state = container.read(homeNotifierProvider);
      expect(state.recommendedShops.length, 2);
      expect(state.recommendedShops, [...initialShops, ...moreShops]);
      expect(state.recommendedPage, 1);
      expect(state.hasMoreRecommended, isFalse);
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

    test('loadMoreRecommended does not load if hasMore is false', () async {
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
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();

      clearInteractions(mockGetFilteredShopsUseCase);

      await notifier.loadMoreRecommended();

      verifyNever(() => mockGetFilteredShopsUseCase(any()));
    });

    test(
      'loadMoreRecommended sets isLoadingMoreRecommended during load',
      () async {
        when(
          () => mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const Right([]));

        int callCount = 0;
        when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
          invocation,
        ) async {
          final filter = invocation.positionalArguments[0] as BeautyShopFilter;
          if (filter.sortBy == 'RATING' && filter.minRating == null) {
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
          ],
        );

        final notifier = container.read(homeNotifierProvider.notifier);
        await notifier.loadData();

        final future = notifier.loadMoreRecommended();

        expect(
          container.read(homeNotifierProvider).isLoadingMoreRecommended,
          isTrue,
        );

        await future;

        expect(
          container.read(homeNotifierProvider).isLoadingMoreRecommended,
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
        if (filter.sortBy == 'RATING' && filter.minRating == null) {
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
        ],
      );

      final notifier = container.read(homeNotifierProvider.notifier);
      await notifier.loadData();
      await notifier.loadMoreRecommended();

      var state = container.read(homeNotifierProvider);
      expect(state.recommendedPage, 1);
      expect(state.hasMoreRecommended, isFalse);

      await notifier.refresh();

      state = container.read(homeNotifierProvider);
      expect(state.recommendedPage, 0);
      expect(state.hasMoreRecommended, isTrue);
    });
  });
}
