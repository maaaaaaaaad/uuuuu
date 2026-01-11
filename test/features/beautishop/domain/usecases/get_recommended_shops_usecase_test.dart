import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/usecase/usecase.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_recommended_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBeautyShopRepository extends Mock implements BeautyShopRepository {}

void main() {
  late GetRecommendedShopsUseCase useCase;
  late MockBeautyShopRepository mockRepository;

  setUp(() {
    mockRepository = MockBeautyShopRepository();
    useCase = GetRecommendedShopsUseCase(mockRepository);
  });

  const testShops = [
    BeautyShop(id: '1', name: '추천샵 A', address: '강남구', rating: 4.9),
    BeautyShop(id: '2', name: '추천샵 B', address: '서초구', rating: 4.8),
  ];

  group('GetRecommendedShopsUseCase', () {
    test('returns list of recommended shops on success', () async {
      when(() => mockRepository.getRecommendedShops())
          .thenAnswer((_) async => const Right(testShops));

      final result = await useCase(NoParams());

      expect(result, const Right(testShops));
      verify(() => mockRepository.getRecommendedShops()).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => mockRepository.getRecommendedShops())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final result = await useCase(NoParams());

      expect(result.isLeft(), true);
    });
  });
}
