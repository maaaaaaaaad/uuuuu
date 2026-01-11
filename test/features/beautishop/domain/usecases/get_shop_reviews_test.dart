import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';

class MockBeautyShopRepository implements BeautyShopRepository {
  Either<Failure, List<ShopReview>>? mockResult;

  @override
  Future<Either<Failure, List<ShopReview>>> getShopReviews(String shopId) async {
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

    test('should return list of ShopReview when successful', () async {
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

      mockRepository.mockResult = Right(reviews);

      final result = await useCase(shopId: '1');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (reviewList) {
          expect(reviewList.length, 2);
          expect(reviewList[0].authorName, '김민지');
        },
      );
    });

    test('should return Failure when repository call fails', () async {
      mockRepository.mockResult = const Left(ServerFailure('서버 오류'));

      final result = await useCase(shopId: '1');

      expect(result.isLeft(), isTrue);
    });
  });
}
