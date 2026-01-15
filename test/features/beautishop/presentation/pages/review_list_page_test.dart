import 'dart:async';

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
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/create_review_usecase.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/widgets/pill_chip.dart';

class MockGetShopReviews extends GetShopReviews {
  PagedShopReviews? mockResult;

  MockGetShopReviews() : super(repository: _MockBeautyShopRepository());

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

class MockCreateReviewUseCase extends CreateReviewUseCase {
  MockCreateReviewUseCase() : super(repository: _MockReviewRepository());

  @override
  Future<Either<Failure, Review>> call({
    required String shopId,
    int? rating,
    String? content,
    List<String>? images,
  }) async {
    return Right(Review(
      id: 'new-review',
      shopId: shopId,
      memberId: 'member-1',
      rating: rating ?? 5,
      content: content ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

class _MockBeautyShopRepository implements BeautyShopRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockReviewRepository implements ReviewRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ReviewListPage', () {
    late MockGetShopReviews mockGetShopReviews;
    late MockCreateReviewUseCase mockCreateReviewUseCase;

    setUp(() {
      mockGetShopReviews = MockGetShopReviews();
      mockCreateReviewUseCase = MockCreateReviewUseCase();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          getShopReviewsUseCaseProvider.overrideWithValue(mockGetShopReviews),
          createReviewUseCaseProvider.overrideWithValue(mockCreateReviewUseCase),
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

    group('UI Redesign', () {
      testWidgets('has lavender gradient background', (tester) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(Scaffold),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.gradient, isNotNull);
      });

      testWidgets('has BackdropFilter for glassmorphism', (tester) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
      });

      testWidgets('uses PillChip for sort tabs', (tester) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(PillChip), findsWidgets);
      });

      testWidgets('CircularProgressIndicator has mint color', (tester) async {
        mockGetShopReviews.mockResult = null;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              getShopReviewsUseCaseProvider.overrideWithValue(
                _CompleterMockGetShopReviews(),
              ),
              createReviewUseCaseProvider.overrideWithValue(
                mockCreateReviewUseCase,
              ),
            ],
            child: const MaterialApp(
              home: ReviewListPage(shopId: 'test-shop-id', shopName: '테스트 샵'),
            ),
          ),
        );
        await tester.pump();

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, AppColors.mint);
      });

      testWidgets('FAB has gradient decoration', (tester) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasGradientFab = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration &&
              decoration.gradient != null &&
              decoration.shape == BoxShape.circle) {
            hasGradientFab = true;
            break;
          }
        }
        expect(hasGradientFab, isTrue);
      });

      testWidgets('empty state has mint colored icon', (tester) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.rate_review_outlined),
        );
        expect(icon.color, AppColors.mint);
      });

      testWidgets('empty state has write review inducement button', (
        tester,
      ) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('첫 리뷰 작성하기'), findsOneWidget);
      });

      testWidgets('empty state button has gradient decoration', (
        tester,
      ) async {
        mockGetShopReviews.mockResult = const PagedShopReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final containers = tester.widgetList<Container>(find.byType(Container));
        bool hasGradientButton = false;
        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration && decoration.gradient != null) {
            final child = container.child;
            if (child != null) {
              hasGradientButton = true;
              break;
            }
          }
        }
        expect(hasGradientButton, isTrue);
      });
    });
  });
}

class _CompleterMockGetShopReviews extends GetShopReviews {
  _CompleterMockGetShopReviews() : super(repository: _MockBeautyShopRepository());

  @override
  Future<Either<Failure, PagedShopReviews>> call({
    required String shopId,
    int page = 0,
    int size = 20,
    ReviewSortType sort = ReviewSortType.createdAtDesc,
  }) {
    return Completer<Either<Failure, PagedShopReviews>>().future;
  }
}
