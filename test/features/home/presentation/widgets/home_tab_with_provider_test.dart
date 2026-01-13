import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_http_client.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

void main() {
  late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;

  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
    registerFallbackValue(FakeBeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        getFilteredShopsUseCaseProvider.overrideWithValue(
          mockGetFilteredShopsUseCase,
        ),
        getCategoriesUseCaseProvider.overrideWithValue(
          mockGetCategoriesUseCase,
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: HomeTab())),
    );
  }

  void setupSuccessfulMocks() {
    const categories = [
      Category(id: '1', name: 'Nail'),
      Category(id: '2', name: 'Lash'),
    ];
    const nearbyShops = [
      BeautyShop(
        id: '3',
        name: 'Nearby Popular Shop',
        address: 'Gangnam',
        rating: 4.9,
      ),
    ];
    const recommendedShops = [
      BeautyShop(
        id: '1',
        name: 'Recommended Shop',
        address: 'Seoul',
        rating: 4.8,
      ),
    ];
    const newShops = [
      BeautyShop(id: '2', name: 'New Shop', address: 'Busan', isNew: true),
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
          PagedBeautyShops(items: newShops, hasNext: false, totalElements: 1),
        );
      }
      return const Right(
        PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
      );
    });
  }

  group('HomeTab with Provider', () {
    testWidgets('displays categories from provider', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CategorySection), findsOneWidget);
    });

    testWidgets('displays recommended shops from provider', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('추천 샵'), findsOneWidget);
      expect(find.text('Recommended Shop'), findsOneWidget);
    });

    testWidgets('displays new shops from provider', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('새로 입점한 샵'), findsOneWidget);
    });

    testWidgets('calls loadData on init', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(() => mockGetCategoriesUseCase()).called(1);
      verify(() => mockGetFilteredShopsUseCase(any())).called(3);
    });

    testWidgets('pull to refresh calls provider refresh', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      clearInteractions(mockGetCategoriesUseCase);
      clearInteractions(mockGetFilteredShopsUseCase);

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => mockGetCategoriesUseCase()).called(1);
      verify(() => mockGetFilteredShopsUseCase(any())).called(3);
    });

    testWidgets('shows loading indicator when loading more recommended shops', (
      tester,
    ) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const recommendedShops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

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
                items: recommendedShops,
                hasNext: true,
                totalElements: 10,
              ),
            );
          } else {
            await Future.delayed(const Duration(milliseconds: 100));
            return const Right(
              PagedBeautyShops(
                items: [BeautyShop(id: '2', name: 'Shop2', address: 'Busan')],
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

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollable, const Offset(0, -5000));
      await tester.pump();

      expect(
        find.byKey(const Key('recommended_loading_indicator')),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('calls loadMoreRecommended when scrolling near bottom', (
      tester,
    ) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const initialShops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
      ];
      const moreShops = [
        BeautyShop(id: '2', name: 'Shop2', address: 'Busan', rating: 4.7),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

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

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollable, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(recommendedCallCount, greaterThan(1));
      expect(find.text('Shop2'), findsOneWidget);
    });

    testWidgets('does not call loadMore when hasMore is false', (tester) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const shops = [
        BeautyShop(id: '1', name: 'Shop1', address: 'Seoul', rating: 4.8),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

      int callCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'RATING' && filter.minRating == null) {
          callCount++;
          return const Right(
            PagedBeautyShops(items: shops, hasNext: false, totalElements: 1),
          );
        }
        return const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final initialCallCount = callCount;

      final scrollable = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollable, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(callCount, initialCallCount);
    });
  });
}
