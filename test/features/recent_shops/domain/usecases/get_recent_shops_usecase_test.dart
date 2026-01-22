import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRecentShopsRepository extends Mock implements RecentShopsRepository {}

void main() {
  late GetRecentShopsUseCase useCase;
  late MockRecentShopsRepository mockRepository;

  setUp(() {
    mockRepository = MockRecentShopsRepository();
    useCase = GetRecentShopsUseCase(mockRepository);
  });

  final tRecentShops = [
    RecentShop(
      shopId: 'shop-1',
      shopName: 'Test Shop 1',
      thumbnailUrl: 'https://example.com/image1.jpg',
      address: 'Test Address 1',
      rating: 4.5,
      viewedAt: DateTime(2024, 1, 15, 10, 30),
    ),
    RecentShop(
      shopId: 'shop-2',
      shopName: 'Test Shop 2',
      thumbnailUrl: null,
      address: 'Test Address 2',
      rating: 3.8,
      viewedAt: DateTime(2024, 1, 14, 14, 0),
    ),
  ];

  group('GetRecentShopsUseCase', () {
    test('should return list of recent shops from repository', () async {
      when(() => mockRepository.getRecentShops())
          .thenAnswer((_) async => Right(tRecentShops));

      final result = await useCase();

      expect(result, Right(tRecentShops));
      verify(() => mockRepository.getRecentShops()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getRecentShops())
          .thenAnswer((_) async => const Left(CacheFailure('Error')));

      final result = await useCase();

      expect(result, isA<Left<Failure, List<RecentShop>>>());
    });

    test('should return empty list when no recent shops', () async {
      when(() => mockRepository.getRecentShops())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase();

      expect(result, const Right(<RecentShop>[]));
      verify(() => mockRepository.getRecentShops()).called(1);
    });
  });
}
