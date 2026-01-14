import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';

class MockBeautyShopRepository implements BeautyShopRepository {
  Either<Failure, PagedShopReviews>? mockResult;
  String? capturedShopId;
  int? capturedPage;
  int? capturedSize;
  String? capturedSort;

  @override
  Future<Either<Failure, PagedShopReviews>> getShopReviews(
    String shopId, {
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    capturedShopId = shopId;
    capturedPage = page;
    capturedSize = size;
    capturedSort = sort;
    return mockResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetShopReviews', () {
    late GetShopReviews useCase;
    late MockBeautyShopRepository mockRepository;

    setUp(() {
      mockRepository = MockBeautyShopRepository();
      useCase = GetShopReviews(repository: mockRepository);
    });

    final reviews = [
      ShopReview(
        id: '1',
        authorName: '김민지',
        rating: 4.5,
        content: '너무 좋아요!',
        createdAt: DateTime(2024, 1, 15),
      ),
      ShopReview(
        id: '2',
        authorName: '박서연',
        rating: 5.0,
        content: '최고입니다',
        createdAt: DateTime(2024, 1, 10),
      ),
    ];

    final pagedReviews = PagedShopReviews(
      items: reviews,
      hasNext: true,
      totalElements: 10,
    );

    test('should return PagedShopReviews when successful', () async {
      mockRepository.mockResult = Right(pagedReviews);

      final result = await useCase(shopId: 'shop-1');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (paged) {
          expect(paged.items.length, 2);
          expect(paged.hasNext, isTrue);
          expect(paged.totalElements, 10);
        },
      );
    });

    test('should pass default page and size to repository', () async {
      mockRepository.mockResult = Right(pagedReviews);

      await useCase(shopId: 'shop-1');

      expect(mockRepository.capturedPage, 0);
      expect(mockRepository.capturedSize, 20);
      expect(mockRepository.capturedSort, 'createdAt,desc');
    });

    test('should pass custom page and size to repository', () async {
      mockRepository.mockResult = Right(pagedReviews);

      await useCase(shopId: 'shop-1', page: 2, size: 10);

      expect(mockRepository.capturedPage, 2);
      expect(mockRepository.capturedSize, 10);
    });

    test('should pass ratingDesc sort to repository', () async {
      mockRepository.mockResult = Right(pagedReviews);

      await useCase(shopId: 'shop-1', sort: ReviewSortType.ratingDesc);

      expect(mockRepository.capturedSort, 'rating,desc');
    });

    test('should pass ratingAsc sort to repository', () async {
      mockRepository.mockResult = Right(pagedReviews);

      await useCase(shopId: 'shop-1', sort: ReviewSortType.ratingAsc);

      expect(mockRepository.capturedSort, 'rating,asc');
    });

    test('should return Failure when repository call fails', () async {
      mockRepository.mockResult = const Left(ServerFailure('서버 오류'));

      final result = await useCase(shopId: 'shop-1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('ReviewSortType', () {
    test('createdAtDesc should have correct apiValue', () {
      expect(ReviewSortType.createdAtDesc.apiValue, 'createdAt,desc');
    });

    test('ratingDesc should have correct apiValue', () {
      expect(ReviewSortType.ratingDesc.apiValue, 'rating,desc');
    });

    test('ratingAsc should have correct apiValue', () {
      expect(ReviewSortType.ratingAsc.apiValue, 'rating,asc');
    });

    test('createdAtDesc should have correct displayName', () {
      expect(ReviewSortType.createdAtDesc.displayName, '최신순');
    });

    test('ratingDesc should have correct displayName', () {
      expect(ReviewSortType.ratingDesc.displayName, '평점 높은순');
    });

    test('ratingAsc should have correct displayName', () {
      expect(ReviewSortType.ratingAsc.displayName, '평점 낮은순');
    });
  });
}
