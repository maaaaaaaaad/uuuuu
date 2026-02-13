import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';
import 'package:jellomark/features/favorite/domain/usecases/add_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/remove_favorite_usecase.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:jellomark/features/review/domain/usecases/get_my_reviews_usecase.dart';
import 'package:jellomark/features/review/presentation/pages/my_reviews_page.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyReviewsUseCase extends Mock implements GetMyReviewsUseCase {}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

class MockAddFavoriteUseCase extends Mock implements AddFavoriteUseCase {}

class MockRemoveFavoriteUseCase extends Mock implements RemoveFavoriteUseCase {}

class FakeGetFavoritesParams extends Fake implements GetFavoritesParams {}

void main() {
  late MockGetMyReviewsUseCase mockGetMyReviewsUseCase;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;
  late MockAddFavoriteUseCase mockAddFavoriteUseCase;
  late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;

  setUpAll(() {
    registerFallbackValue(FakeGetFavoritesParams());
  });

  setUp(() {
    mockGetMyReviewsUseCase = MockGetMyReviewsUseCase();
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    mockAddFavoriteUseCase = MockAddFavoriteUseCase();
    mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();

    when(() => mockGetFavoritesUseCase(any())).thenAnswer(
      (_) async => const Right(
        PagedFavorites(
          items: [],
          hasNext: false,
          totalElements: 0,
          totalPages: 0,
          page: 0,
          size: 20,
        ),
      ),
    );
  });

  final tReview = Review(
    id: '1',
    shopId: 'shop-1',
    memberId: 'member-1',
    rating: 5,
    content: 'Great service!',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  final tPagedReviews = PagedReviews(
    items: [tReview],
    hasNext: false,
    totalElements: 1,
  );

  Widget createMyReviewsPage() {
    return ProviderScope(
      overrides: [
        getMyReviewsUseCaseProvider.overrideWithValue(mockGetMyReviewsUseCase),
        getFavoritesUseCaseProvider.overrideWithValue(mockGetFavoritesUseCase),
        addFavoriteUseCaseProvider.overrideWithValue(mockAddFavoriteUseCase),
        removeFavoriteUseCaseProvider.overrideWithValue(mockRemoveFavoriteUseCase),
        currentLocationProvider.overrideWith((ref) => Future.value(null)),
      ],
      child: const MaterialApp(
        home: MyReviewsPage(),
      ),
    );
  }

  group('MyReviewsPage', () {
    testWidgets('should render my reviews page', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.byType(MyReviewsPage), findsOneWidget);
    });

    testWidgets('should display app bar with title', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.text('내가 쓴 리뷰'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display reviews when loaded', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.text('Great service!'), findsOneWidget);
    });

    testWidgets('should display empty state when no reviews', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20)).thenAnswer(
        (_) async => const Right(PagedReviews(
          items: [],
          hasNext: false,
          totalElements: 0,
        )),
      );

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.text('작성한 리뷰가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('should display error state when loading fails', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.text('서버 오류'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display retry button on error', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should display star rating when review has rating',
        (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('should display edit and delete buttons', (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog on delete tap',
        (tester) async {
      when(() => mockGetMyReviewsUseCase(page: 0, size: 20))
          .thenAnswer((_) async => Right(tPagedReviews));

      await tester.pumpWidget(createMyReviewsPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('리뷰 삭제'), findsOneWidget);
      expect(find.text('이 리뷰를 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });
  });
}
