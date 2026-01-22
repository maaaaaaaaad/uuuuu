import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRecentShopsRepository extends Mock implements RecentShopsRepository {}

void main() {
  late AddRecentShopUseCase useCase;
  late MockRecentShopsRepository mockRepository;

  setUp(() {
    mockRepository = MockRecentShopsRepository();
    useCase = AddRecentShopUseCase(mockRepository);
  });

  final tRecentShop = RecentShop(
    shopId: 'shop-1',
    shopName: 'Test Shop',
    thumbnailUrl: 'https://example.com/image.jpg',
    address: 'Test Address',
    rating: 4.5,
    viewedAt: DateTime(2024, 1, 15, 10, 30),
  );

  setUpAll(() {
    registerFallbackValue(tRecentShop);
  });

  group('AddRecentShopUseCase', () {
    test('should add recent shop via repository', () async {
      when(() => mockRepository.addRecentShop(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(tRecentShop);

      expect(result, const Right(null));
      verify(() => mockRepository.addRecentShop(tRecentShop)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.addRecentShop(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Error')));

      final result = await useCase(tRecentShop);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
