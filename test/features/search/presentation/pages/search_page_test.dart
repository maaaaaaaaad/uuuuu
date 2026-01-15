import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/home/presentation/providers/home_provider.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:jellomark/features/search/presentation/pages/search_page.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockManageSearchHistoryUseCase extends Mock
    implements ManageSearchHistoryUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

void main() {
  late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;
  late MockManageSearchHistoryUseCase mockManageSearchHistoryUseCase;

  setUpAll(() {
    registerFallbackValue(FakeBeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
    mockManageSearchHistoryUseCase = MockManageSearchHistoryUseCase();

    when(
      () => mockManageSearchHistoryUseCase.getSearchHistory(),
    ).thenAnswer((_) async => const Right([]));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        getFilteredShopsUseCaseProvider.overrideWithValue(
          mockGetFilteredShopsUseCase,
        ),
        manageSearchHistoryUseCaseProvider.overrideWithValue(
          mockManageSearchHistoryUseCase,
        ),
      ],
      child: const MaterialApp(home: SearchPage()),
    );
  }

  group('SearchPage', () {
    testWidgets('should display search text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display cancel button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('should show search history when available', (tester) async {
      final historyList = [
        SearchHistory(keyword: '강남 네일', searchedAt: DateTime(2024, 1, 15)),
        SearchHistory(keyword: '홍대 헤어', searchedAt: DateTime(2024, 1, 14)),
      ];
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => Right(historyList));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('강남 네일'), findsOneWidget);
      expect(find.text('홍대 헤어'), findsOneWidget);
    });

    testWidgets('should display recent searches label', (tester) async {
      final historyList = [
        SearchHistory(keyword: '테스트', searchedAt: DateTime(2024, 1, 15)),
      ];
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => Right(historyList));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('최근 검색어'), findsOneWidget);
    });

    testWidgets('should search when text is submitted', (tester) async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '강남');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(() => mockGetFilteredShopsUseCase(any())).called(1);
    });

    testWidgets('should display search results', (tester) async {
      const shops = [
        BeautyShop(
          id: '1',
          name: '강남 네일샵',
          address: '강남구 역삼동',
          rating: 4.5,
          reviewCount: 10,
        ),
      ];
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(
            items: shops,
            hasNext: false,
            totalElements: 1,
          ),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '강남');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('강남 네일샵'), findsOneWidget);
    });
  });
}
