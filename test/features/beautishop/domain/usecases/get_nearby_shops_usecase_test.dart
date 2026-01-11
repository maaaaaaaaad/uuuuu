import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_nearby_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockBeautyShopRepository extends Mock implements BeautyShopRepository {}

void main() {
  late GetNearbyShopsUseCase useCase;
  late MockBeautyShopRepository mockRepository;

  setUp(() {
    mockRepository = MockBeautyShopRepository();
    useCase = GetNearbyShopsUseCase(mockRepository);
  });

  const testShops = [
    BeautyShop(id: '1', name: '네일샵 A', address: '강남구'),
    BeautyShop(id: '2', name: '네일샵 B', address: '서초구'),
  ];

  group('GetNearbyShopsUseCase', () {
    test('returns list of nearby shops on success', () async {
      when(() => mockRepository.getNearbyShops(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          )).thenAnswer((_) async => const Right(testShops));

      final result = await useCase(const GetNearbyShopsParams(
        latitude: 37.5665,
        longitude: 126.9780,
      ));

      expect(result, const Right(testShops));
      verify(() => mockRepository.getNearbyShops(
            latitude: 37.5665,
            longitude: 126.9780,
            radiusKm: null,
          )).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => mockRepository.getNearbyShops(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          )).thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final result = await useCase(const GetNearbyShopsParams(
        latitude: 37.5665,
        longitude: 126.9780,
      ));

      expect(result.isLeft(), true);
    });

    test('passes radiusKm parameter to repository', () async {
      when(() => mockRepository.getNearbyShops(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          )).thenAnswer((_) async => const Right(testShops));

      await useCase(const GetNearbyShopsParams(
        latitude: 37.5665,
        longitude: 126.9780,
        radiusKm: 5.0,
      ));

      verify(() => mockRepository.getNearbyShops(
            latitude: 37.5665,
            longitude: 126.9780,
            radiusKm: 5.0,
          )).called(1);
    });
  });
}
