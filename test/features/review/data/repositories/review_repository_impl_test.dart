import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/review/data/datasources/review_remote_datasource.dart';
import 'package:jellomark/features/review/data/models/paged_reviews_model.dart';
import 'package:jellomark/features/review/data/models/review_model.dart';
import 'package:jellomark/features/review/data/repositories/review_repository_impl.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRemoteDataSource extends Mock
    implements ReviewRemoteDataSource {}

void main() {
  late ReviewRepositoryImpl repository;
  late MockReviewRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tReviewModel = ReviewModel(
    id: '1',
    shopId: 'shop-1',
    memberId: 'member-1',
    rating: 5,
    content: 'Great!',
    images: [],
    createdAt: '2024-01-15T10:30:00Z',
    updatedAt: '2024-01-15T10:30:00Z',
  );

  final tPagedReviewsModel = PagedReviewsModel(
    items: const [tReviewModel],
    hasNext: true,
    totalElements: 10,
  );

  group('getShopReviews', () {
    const tShopId = 'shop-1';
    const tPage = 0;
    const tSize = 20;

    test('should return PagedReviews when data source call is successful',
        () async {
      when(() => mockDataSource.getShopReviews(
            shopId: tShopId,
            page: tPage,
            size: tSize,
          )).thenAnswer((_) async => tPagedReviewsModel);

      final result = await repository.getShopReviews(
        shopId: tShopId,
        page: tPage,
        size: tSize,
      );

      expect(result, isA<Right<Failure, PagedReviews>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (pagedReviews) {
          expect(pagedReviews.items.length, 1);
          expect(pagedReviews.hasNext, true);
          expect(pagedReviews.totalElements, 10);
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.getShopReviews(
            shopId: tShopId,
            page: tPage,
            size: tSize,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.getShopReviews(
        shopId: tShopId,
        page: tPage,
        size: tSize,
      );

      expect(result, isA<Left<Failure, PagedReviews>>());
    });
  });

  group('createReview', () {
    const tShopId = 'shop-1';
    const tRating = 5;
    const tContent = 'Great!';

    test('should return Review when data source call is successful', () async {
      when(() => mockDataSource.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenAnswer((_) async => tReviewModel);

      final result = await repository.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Right<Failure, Review>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (review) {
          expect(review.id, '1');
          expect(review.rating, 5);
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Left<Failure, Review>>());
    });

    test(
        'should extract detail from ProblemDetail response on DioException',
        () async {
      when(() => mockDataSource.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 409,
            data: {
              'type': 'about:blank',
              'title': 'Conflict',
              'status': 409,
              'detail': '이미 리뷰를 작성하셨습니다',
            },
          ),
          message: 'Http status error [409]',
        ),
      );

      final result = await repository.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      result.fold(
        (failure) => expect(failure.message, '이미 리뷰를 작성하셨습니다'),
        (_) => fail('Should not return success'),
      );
    });

    test(
        'should extract message from ErrorResponse on DioException',
        () async {
      when(() => mockDataSource.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Unexpected server error',
            },
          ),
          message: 'Http status error [500]',
        ),
      );

      final result = await repository.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      result.fold(
        (failure) => expect(failure.message, 'Unexpected server error'),
        (_) => fail('Should not return success'),
      );
    });

    test(
        'should fallback to Dio message when response data is not a Map',
        () async {
      when(() => mockDataSource.createReview(
            shopId: tShopId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: 'plain text error',
          ),
          message: 'Connection refused',
        ),
      );

      final result = await repository.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
      );

      result.fold(
        (failure) => expect(failure.message, 'Connection refused'),
        (_) => fail('Should not return success'),
      );
    });
  });

  group('updateReview', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';
    const tRating = 4;
    const tContent = 'Updated!';

    test('should return Review when data source call is successful', () async {
      when(() => mockDataSource.updateReview(
            shopId: tShopId,
            reviewId: tReviewId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenAnswer((_) async => tReviewModel);

      final result = await repository.updateReview(
        shopId: tShopId,
        reviewId: tReviewId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Right<Failure, Review>>());
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.updateReview(
            shopId: tShopId,
            reviewId: tReviewId,
            rating: tRating,
            content: tContent,
            images: null,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.updateReview(
        shopId: tShopId,
        reviewId: tReviewId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<Left<Failure, Review>>());
    });
  });

  group('deleteReview', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';

    test('should return void when data source call is successful', () async {
      when(() => mockDataSource.deleteReview(
            shopId: tShopId,
            reviewId: tReviewId,
          )).thenAnswer((_) async {});

      final result = await repository.deleteReview(
        shopId: tShopId,
        reviewId: tReviewId,
      );

      expect(result, isA<Right<Failure, void>>());
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.deleteReview(
            shopId: tShopId,
            reviewId: tReviewId,
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.deleteReview(
        shopId: tShopId,
        reviewId: tReviewId,
      );

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
