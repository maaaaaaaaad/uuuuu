import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/search/domain/entities/search_history.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:jellomark/features/search/presentation/providers/search_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFilteredShopsUseCase extends Mock
    implements GetFilteredShopsUseCase {}

class MockManageSearchHistoryUseCase extends Mock
    implements ManageSearchHistoryUseCase {}

class FakeBeautyShopFilter extends Fake implements BeautyShopFilter {}

void main() {
  late SearchNotifier notifier;
  late MockGetFilteredShopsUseCase mockGetFilteredShopsUseCase;
  late MockManageSearchHistoryUseCase mockManageSearchHistoryUseCase;

  setUpAll(() {
    registerFallbackValue(FakeBeautyShopFilter());
  });

  setUp(() {
    mockGetFilteredShopsUseCase = MockGetFilteredShopsUseCase();
    mockManageSearchHistoryUseCase = MockManageSearchHistoryUseCase();
    notifier = SearchNotifier(
      getFilteredShopsUseCase: mockGetFilteredShopsUseCase,
      manageSearchHistoryUseCase: mockManageSearchHistoryUseCase,
    );
  });

  group('SearchState', () {
    test('initial state has correct values', () {
      expect(notifier.state.query, equals(''));
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.searchHistory, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
      expect(notifier.state.hasMore, isTrue);
      expect(notifier.state.page, equals(0));
    });
  });

  group('loadSearchHistory', () {
    test('should load search history from repository', () async {
      final historyList = [
        SearchHistory(keyword: '강남 네일', searchedAt: DateTime(2024, 1, 15)),
      ];
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => Right(historyList));

      await notifier.loadSearchHistory();

      expect(notifier.state.searchHistory.length, equals(1));
      expect(notifier.state.searchHistory[0].keyword, equals('강남 네일'));
    });

    test('should handle error when loading history fails', () async {
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => const Left(CacheFailure('조회 실패')));

      await notifier.loadSearchHistory();

      expect(notifier.state.searchHistory, isEmpty);
    });
  });

  group('search', () {
    test('should update query and search results', () async {
      final shops = <BeautyShop>[
        const BeautyShop(
          id: '1',
          name: '강남 네일샵',
          address: '강남구',
          rating: 4.5,
          reviewCount: 10,
        ),
      ];
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          PagedBeautyShops(items: shops, hasNext: false, totalElements: 1),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('강남');

      expect(notifier.state.query, equals('강남'));
      expect(notifier.state.results.length, equals(1));
      expect(notifier.state.results[0].name, equals('강남 네일샵'));
    });

    test('should save search keyword to history', () async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('홍대');

      verify(
        () => mockManageSearchHistoryUseCase.saveSearchHistory('홍대'),
      ).called(1);
    });

    test('should not search when query is empty', () async {
      await notifier.search('');

      verifyNever(() => mockGetFilteredShopsUseCase(any()));
    });

    test('should set isLoading during search', () async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Right(
          const PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        );
      });
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      final searchFuture = notifier.search('test');

      expect(notifier.state.isLoading, isTrue);

      await searchFuture;

      expect(notifier.state.isLoading, isFalse);
    });

    test('should reset page when new search', () async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(items: [], hasNext: true, totalElements: 0),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('first');
      await notifier.search('second');

      expect(notifier.state.page, equals(0));
    });
  });

  group('loadMore', () {
    test('should load more results and increment page', () async {
      final firstPage = <BeautyShop>[
        const BeautyShop(
          id: '1',
          name: '첫번째',
          address: '',
          rating: 4.0,
          reviewCount: 0,
        ),
      ];
      final secondPage = <BeautyShop>[
        const BeautyShop(
          id: '2',
          name: '두번째',
          address: '',
          rating: 4.0,
          reviewCount: 0,
        ),
      ];

      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          PagedBeautyShops(items: firstPage, hasNext: true, totalElements: 2),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('test');

      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          PagedBeautyShops(items: secondPage, hasNext: false, totalElements: 2),
        ),
      );

      await notifier.loadMore();

      expect(notifier.state.results.length, equals(2));
      expect(notifier.state.page, equals(1));
      expect(notifier.state.hasMore, isFalse);
    });

    test('should not load more when no more results', () async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(items: [], hasNext: false, totalElements: 0),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('test');

      await notifier.loadMore();

      verify(() => mockGetFilteredShopsUseCase(any())).called(1);
    });
  });

  group('deleteHistory', () {
    test('should delete keyword from history', () async {
      when(
        () => mockManageSearchHistoryUseCase.deleteSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockManageSearchHistoryUseCase.getSearchHistory(),
      ).thenAnswer((_) async => const Right([]));

      await notifier.deleteHistory('강남 네일');

      verify(
        () => mockManageSearchHistoryUseCase.deleteSearchHistory('강남 네일'),
      ).called(1);
    });
  });

  group('clearHistory', () {
    test('should clear all history', () async {
      when(
        () => mockManageSearchHistoryUseCase.clearAllSearchHistory(),
      ).thenAnswer((_) async => const Right(null));

      await notifier.clearHistory();

      verify(
        () => mockManageSearchHistoryUseCase.clearAllSearchHistory(),
      ).called(1);
      expect(notifier.state.searchHistory, isEmpty);
    });
  });

  group('clearSearch', () {
    test('should clear query and results', () async {
      when(() => mockGetFilteredShopsUseCase(any())).thenAnswer(
        (_) async => Right(
          const PagedBeautyShops(
            items: [
              BeautyShop(
                id: '1',
                name: 'test',
                address: '',
                rating: 4.0,
                reviewCount: 0,
              ),
            ],
            hasNext: false,
            totalElements: 1,
          ),
        ),
      );
      when(
        () => mockManageSearchHistoryUseCase.saveSearchHistory(any()),
      ).thenAnswer((_) async => const Right(null));

      await notifier.search('test');
      notifier.clearSearch();

      expect(notifier.state.query, equals(''));
      expect(notifier.state.results, isEmpty);
    });
  });
}
