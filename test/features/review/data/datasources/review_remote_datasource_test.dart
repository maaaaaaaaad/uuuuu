import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/review/data/datasources/review_remote_datasource.dart';
import 'package:jellomark/features/review/data/models/paged_reviews_model.dart';
import 'package:jellomark/features/review/data/models/review_model.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ReviewRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ReviewRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('getShopReviews', () {
    const tShopId = 'shop-1';
    const tPage = 0;
    const tSize = 20;

    final tResponseData = {
      'items': [
        {
          'id': '1',
          'shopId': 'shop-1',
          'memberId': 'member-1',
          'rating': 5,
          'content': 'Great!',
          'images': <dynamic>[],
          'createdAt': '2024-01-15T10:30:00Z',
          'updatedAt': '2024-01-15T10:30:00Z',
        }
      ],
      'hasNext': true,
      'totalElements': 10,
    };

    test('should return PagedReviewsModel when API call is successful', () async {
      when(() => mockApiClient.get(
            '/api/beautishops/$tShopId/reviews',
            queryParameters: {'page': tPage, 'size': tSize},
          )).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getShopReviews(
        shopId: tShopId,
        page: tPage,
        size: tSize,
      );

      expect(result, isA<PagedReviewsModel>());
      expect(result.items.length, 1);
      expect(result.items.first.id, '1');
      verify(() => mockApiClient.get(
            '/api/beautishops/$tShopId/reviews',
            queryParameters: {'page': tPage, 'size': tSize},
          )).called(1);
    });
  });

  group('createReview', () {
    const tShopId = 'shop-1';
    const tRating = 5;
    const tContent = 'Great service!';
    final tImages = ['image1.jpg'];

    final tResponseData = {
      'id': '1',
      'shopId': 'shop-1',
      'memberId': 'member-1',
      'rating': 5,
      'content': 'Great service!',
      'images': ['image1.jpg'],
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-01-15T10:30:00Z',
    };

    test('should return ReviewModel when API call is successful', () async {
      when(() => mockApiClient.post(
            '/api/beautishops/$tShopId/reviews',
            data: {
              'rating': tRating,
              'content': tContent,
              'images': tImages,
            },
          )).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.createReview(
        shopId: tShopId,
        rating: tRating,
        content: tContent,
        images: tImages,
      );

      expect(result, isA<ReviewModel>());
      expect(result.id, '1');
      expect(result.rating, 5);
      verify(() => mockApiClient.post(
            '/api/beautishops/$tShopId/reviews',
            data: {
              'rating': tRating,
              'content': tContent,
              'images': tImages,
            },
          )).called(1);
    });
  });

  group('updateReview', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';
    const tRating = 4;
    const tContent = 'Updated review';

    final tResponseData = {
      'id': 'review-1',
      'shopId': 'shop-1',
      'memberId': 'member-1',
      'rating': 4,
      'content': 'Updated review',
      'images': null,
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-01-16T10:30:00Z',
    };

    test('should return ReviewModel when API call is successful', () async {
      when(() => mockApiClient.put(
            '/api/beautishops/$tShopId/reviews/$tReviewId',
            data: {
              'rating': tRating,
              'content': tContent,
            },
          )).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.updateReview(
        shopId: tShopId,
        reviewId: tReviewId,
        rating: tRating,
        content: tContent,
      );

      expect(result, isA<ReviewModel>());
      expect(result.id, 'review-1');
      expect(result.rating, 4);
      verify(() => mockApiClient.put(
            '/api/beautishops/$tShopId/reviews/$tReviewId',
            data: {
              'rating': tRating,
              'content': tContent,
            },
          )).called(1);
    });
  });

  group('deleteReview', () {
    const tShopId = 'shop-1';
    const tReviewId = 'review-1';

    test('should complete successfully when API call is successful', () async {
      when(() => mockApiClient.delete(
            '/api/beautishops/$tShopId/reviews/$tReviewId',
          )).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await expectLater(
        dataSource.deleteReview(shopId: tShopId, reviewId: tReviewId),
        completes,
      );

      verify(() => mockApiClient.delete(
            '/api/beautishops/$tShopId/reviews/$tReviewId',
          )).called(1);
    });
  });
}
