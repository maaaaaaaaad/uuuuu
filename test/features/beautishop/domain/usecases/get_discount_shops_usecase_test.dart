import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/usecase/usecase.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_discount_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBeautyShopRepository extends Mock implements BeautyShopRepository {}

void main() {
  late GetDiscountShopsUseCase useCase;
  late MockBeautyShopRepository mockRepository;

  setUp(() {
    mockRepository = MockBeautyShopRepository();
    useCase = GetDiscountShopsUseCase(mockRepository);
  });

  const testShops = [
    BeautyShop(id: '1', name: '할인샵 A', address: '강남구', discountRate: 30),
    BeautyShop(id: '2', name: '할인샵 B', address: '서초구', discountRate: 20),
  ];

  group('GetDiscountShopsUseCase', () {
    test('returns list of discount shops on success', () async {
      when(() => mockRepository.getDiscountShops())
          .thenAnswer((_) async => const Right(testShops));

      final result = await useCase(NoParams());

      expect(result, const Right(testShops));
      verify(() => mockRepository.getDiscountShops()).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => mockRepository.getDiscountShops())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final result = await useCase(NoParams());

      expect(result.isLeft(), true);
    });
  });
}
