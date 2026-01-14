import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';
import 'package:jellomark/features/beautishop/presentation/pages/review_list_page.dart';
import 'package:jellomark/features/beautishop/presentation/providers/review_list_provider.dart';

class MockGetShopReviews extends GetShopReviews {
  PagedShopReviews? mockResult;

  MockGetShopReviews() : super(repository: _MockRepository());

  @override
  Future<Either<Failure, PagedShopReviews>> call({
    required String shopId,
    int page = 0,
    int size = 20,
    ReviewSortType sort = ReviewSortType.createdAtDesc,
  }) async {
    return Right(mockResult!);
  }
}

class _MockRepository implements BeautyShopRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ReviewListPage', () {
    late MockGetShopReviews mockGetShopReviews;

    setUp(() {
      mockGetShopReviews = MockGetShopReviews();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          getShopReviewsUseCaseProvider.overrideWithValue(mockGetShopReviews),
        ],
        child: const MaterialApp(
          home: ReviewListPage(shopId: 'test-shop-id', shopName: '테스트 샵'),
        ),
      );
    }

    testWidgets('should display empty state when no reviews', (tester) async {
      mockGetShopReviews.mockResult = const PagedShopReviews(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('아직 리뷰가 없어요'), findsOneWidget);
    });

    testWidgets('should display reviews when loaded', (tester) async {
      mockGetShopReviews.mockResult = PagedShopReviews(
        items: [
          ShopReview(
            id: '1',
            authorName: '김민지',
            rating: 4.5,
            content: '좋아요!',
            createdAt: DateTime(2024, 1, 15),
          ),
        ],
        hasNext: false,
        totalElements: 1,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('김민지'), findsOneWidget);
      expect(find.text('좋아요!'), findsOneWidget);
    });

    testWidgets('should display sort tabs', (tester) async {
      mockGetShopReviews.mockResult = const PagedShopReviews(
        items: [],
        hasNext: false,
        totalElements: 0,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('최신순'), findsOneWidget);
      expect(find.text('평점 높은순'), findsOneWidget);
      expect(find.text('평점 낮은순'), findsOneWidget);
    });

    testWidgets('should display total count in app bar', (tester) async {
      mockGetShopReviews.mockResult = const PagedShopReviews(
        items: [],
        hasNext: false,
        totalElements: 25,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('리뷰 25개'), findsOneWidget);
    });

    testWidgets('should display rating only message when no content', (
      tester,
    ) async {
      mockGetShopReviews.mockResult = PagedShopReviews(
        items: [
          ShopReview(
            id: '1',
            authorName: '김민지',
            rating: 5.0,
            content: null,
            createdAt: DateTime(2024, 1, 15),
          ),
        ],
        hasNext: false,
        totalElements: 1,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('평점만 등록됨'), findsOneWidget);
    });
  });
}
