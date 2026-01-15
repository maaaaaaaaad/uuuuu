import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_screen.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/home/presentation/widgets/home_tab.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/features/treatment/presentation/providers/treatment_provider.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/gradient_card.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';
import 'package:jellomark/shared/widgets/sections/search_section.dart';
import 'package:jellomark/shared/widgets/units/shop_card.dart';
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
    registerFallbackValue(const BeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
  });

  final testShops = [
    BeautyShop(
      id: '1',
      name: 'Test Shop 1',
      address: 'Address 1',
      rating: 4.5,
      reviewCount: 10,
    ),
    BeautyShop(
      id: '2',
      name: 'Test Shop 2',
      address: 'Address 2',
      rating: 4.0,
      reviewCount: 5,
    ),
  ];

  final testCategories = [
    const Category(id: '1', name: '네일'),
    const Category(id: '2', name: '헤어'),
  ];

  void setupMocks() {
    when(
      () => mockGetCategoriesUseCase(),
    ).thenAnswer((_) async => Right(testCategories));

    when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
      (_) async => Right(
        PagedBeautyShops(items: testShops, hasNext: false, totalElements: 2),
      ),
    );
  }

  Widget buildTestWidget({
    required MockGetFilteredShopsUseCase filteredShopsUseCase,
    required MockGetCategoriesUseCase categoriesUseCase,
  }) {
    return ProviderScope(
      overrides: [
        getFilteredShopsUseCaseProvider.overrideWithValue(filteredShopsUseCase),
        getCategoriesUseCaseProvider.overrideWithValue(categoriesUseCase),
      ],
      child: const MaterialApp(home: Scaffold(body: HomeTab())),
    );
  }

  group('HomeTab', () {
    testWidgets('renders scrollable content', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(HomeTab), findsOneWidget);
    });

    testWidgets('renders search section', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SearchSection), findsOneWidget);
    });

    testWidgets('renders category section when categories exist', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategorySection), findsOneWidget);
    });

    testWidgets('renders section headers for shop lists', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('내 주변 인기 샵'), findsOneWidget);
      expect(find.text('추천 샵'), findsOneWidget);
      expect(find.text('새로 입점한 샵'), findsOneWidget);
    });

    testWidgets('sections are in correct order', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      final searchOffset = tester.getTopLeft(find.byType(SearchSection));
      final categoryOffset = tester.getTopLeft(find.byType(CategorySection));

      expect(searchOffset.dy, lessThan(categoryOffset.dy));
    });

    testWidgets('has RefreshIndicator for pull to refresh', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('has SafeArea to avoid status bar overlap', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('shows floating search icon when scrolled down', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsNothing);

      await tester.fling(
        find.byKey(const Key('home_tab_scroll_view')),
        const Offset(0, -300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsOneWidget);
    });

    testWidgets('hides floating search icon when scrolled back to top', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        buildTestWidget(
          filteredShopsUseCase: mockGetFilteredShopsUseCase,
          categoriesUseCase: mockGetCategoriesUseCase,
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(
        find.byKey(const Key('home_tab_scroll_view')),
        const Offset(0, -300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsOneWidget);

      await tester.fling(
        find.byKey(const Key('home_tab_scroll_view')),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('floating_search_icon')), findsNothing);
    });

    testWidgets('navigates to ShopDetailScreen when shop card is tapped', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getFilteredShopsUseCaseProvider
                .overrideWithValue(mockGetFilteredShopsUseCase),
            getCategoriesUseCaseProvider
                .overrideWithValue(mockGetCategoriesUseCase),
            shopTreatmentsProvider('1').overrideWith((ref) async => []),
            shopReviewsNotifierProvider('1').overrideWith(
              (ref) => _MockShopReviewsNotifier(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeTab())),
        ),
      );
      await tester.pumpAndSettle();

      final shopCard = find.byType(ShopCard).first;
      await tester.tap(shopCard);
      await tester.pumpAndSettle();

      expect(find.byType(ShopDetailScreen), findsOneWidget);
    });

    group('UI Redesign', () {
      testWidgets('renders hero section with GradientCard', (tester) async {
        setupMocks();

        await tester.pumpWidget(
          buildTestWidget(
            filteredShopsUseCase: mockGetFilteredShopsUseCase,
            categoriesUseCase: mockGetCategoriesUseCase,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GradientCard), findsOneWidget);
      });

      testWidgets('hero section contains welcome message', (tester) async {
        setupMocks();

        await tester.pumpWidget(
          buildTestWidget(
            filteredShopsUseCase: mockGetFilteredShopsUseCase,
            categoriesUseCase: mockGetCategoriesUseCase,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('환영'), findsOneWidget);
      });

      testWidgets('RefreshIndicator has mint color', (tester) async {
        setupMocks();

        await tester.pumpWidget(
          buildTestWidget(
            filteredShopsUseCase: mockGetFilteredShopsUseCase,
            categoriesUseCase: mockGetCategoriesUseCase,
          ),
        );
        await tester.pumpAndSettle();

        final refreshIndicator = tester.widget<RefreshIndicator>(
          find.byType(RefreshIndicator),
        );
        expect(refreshIndicator.color, AppColors.mint);
      });
    });
  });
}

class _MockShopReviewsNotifier extends ShopReviewsNotifier {
  _MockShopReviewsNotifier() : super('mock-shop-id', _MockRef());

  @override
  ShopReviewsState get state => const ShopReviewsState();

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> loadMore() async {}
}

class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
