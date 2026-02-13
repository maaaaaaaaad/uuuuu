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
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
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
        currentLocationProvider.overrideWith((ref) async => null),
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
      if (filter.sortBy == 'DISTANCE') {
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

      final scrollView = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollView, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('추천 샵'), findsOneWidget);
      expect(find.text('Recommended Shop'), findsOneWidget);
    });

    testWidgets('displays new shops from provider', (tester) async {
      setupSuccessfulMocks();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scrollView = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollView, const Offset(0, -800));
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

    testWidgets('shows loading indicator when loading more new shops', (
      tester,
    ) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const newShops = [
        BeautyShop(id: '1', name: 'NewShop1', address: 'Seoul', isNew: true),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

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
                items: newShops,
                hasNext: true,
                totalElements: 10,
              ),
            );
          } else {
            await Future.delayed(const Duration(milliseconds: 100));
            return const Right(
              PagedBeautyShops(
                items: [
                  BeautyShop(
                    id: '2',
                    name: 'NewShop2',
                    address: 'Busan',
                    isNew: true,
                  ),
                ],
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
        find.byKey(const Key('new_shops_loading_indicator')),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('calls loadMoreNewShops when scrolling near bottom', (
      tester,
    ) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const initialNewShops = [
        BeautyShop(id: '1', name: 'NewShop1', address: 'Seoul', isNew: true),
      ];
      const moreNewShops = [
        BeautyShop(id: '2', name: 'NewShop2', address: 'Busan', isNew: true),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

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
                items: initialNewShops,
                hasNext: true,
                totalElements: 10,
              ),
            );
          } else {
            return const Right(
              PagedBeautyShops(
                items: moreNewShops,
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

      expect(newShopsCallCount, greaterThan(1));
      expect(find.text('NewShop2'), findsOneWidget);
    });

    testWidgets('does not call loadMoreNewShops when hasMore is false', (
      tester,
    ) async {
      const categories = [Category(id: '1', name: 'Nail')];
      const newShops = [
        BeautyShop(id: '1', name: 'NewShop1', address: 'Seoul', isNew: true),
      ];

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Right(categories));

      int newShopsCallCount = 0;
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((
        invocation,
      ) async {
        final filter = invocation.positionalArguments[0] as BeautyShopFilter;
        if (filter.sortBy == 'CREATED_AT') {
          newShopsCallCount++;
          return const Right(
            PagedBeautyShops(items: newShops, hasNext: false, totalElements: 1),
          );
        }
        return const Right(
          PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final initialCallCount = newShopsCallCount;

      final scrollable = find.byKey(const Key('home_tab_scroll_view'));
      await tester.drag(scrollable, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(newShopsCallCount, initialCallCount);
    });
  });
}
