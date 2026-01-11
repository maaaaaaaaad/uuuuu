import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_detail.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_detail.dart';

class MockBeautyShopRepository implements BeautyShopRepository {
  Either<Failure, ShopDetail>? mockResult;

  @override
  Future<Either<Failure, ShopDetail>> getShopDetail(String shopId) async {
    return mockResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetShopDetail', () {
    late GetShopDetail useCase;
    late MockBeautyShopRepository mockRepository;

    setUp(() {
      mockRepository = MockBeautyShopRepository();
      useCase = GetShopDetail(repository: mockRepository);
    });

    test('should return ShopDetail when repository call is successful', () async {
      const shopDetail = ShopDetail(
        id: '1',
        name: '블루밍 네일',
        address: '서울시 강남구',
        description: '강남 최고의 네일샵',
        phoneNumber: '02-1234-5678',
        rating: 4.8,
        reviewCount: 234,
      );

      mockRepository.mockResult = const Right(shopDetail);

      final result = await useCase(shopId: '1');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (detail) {
          expect(detail.id, '1');
          expect(detail.name, '블루밍 네일');
          expect(detail.description, '강남 최고의 네일샵');
        },
      );
    });

    test('should return Failure when repository call fails', () async {
      mockRepository.mockResult = const Left(ServerFailure('서버 오류'));

      final result = await useCase(shopId: '1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (detail) => fail('Should not return success'),
      );
    });

    test('should pass correct shopId to repository', () async {
      const shopDetail = ShopDetail(
        id: '123',
        name: '테스트 샵',
        address: '주소',
        description: '설명',
        phoneNumber: '010-1234-5678',
      );

      mockRepository.mockResult = const Right(shopDetail);

      final result = await useCase(shopId: '123');

      result.fold(
        (failure) => fail('Should not return failure'),
        (detail) => expect(detail.id, '123'),
      );
    });
  });
}
