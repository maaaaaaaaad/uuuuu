import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_services.dart';

class MockBeautyShopRepository implements BeautyShopRepository {
  Either<Failure, List<ServiceMenu>>? mockResult;

  @override
  Future<Either<Failure, List<ServiceMenu>>> getShopServices(String shopId) async {
    return mockResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetShopServices', () {
    late GetShopServices useCase;
    late MockBeautyShopRepository mockRepository;

    setUp(() {
      mockRepository = MockBeautyShopRepository();
      useCase = GetShopServices(repository: mockRepository);
    });

    test('should return list of ServiceMenu when successful', () async {
      const services = [
        ServiceMenu(id: '1', name: '젤네일 기본', price: 50000),
        ServiceMenu(id: '2', name: '젤네일 아트', price: 70000),
      ];

      mockRepository.mockResult = const Right(services);

      final result = await useCase(shopId: '1');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (menuList) {
          expect(menuList.length, 2);
          expect(menuList[0].name, '젤네일 기본');
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
