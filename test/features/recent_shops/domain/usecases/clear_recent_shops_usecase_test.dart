import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRecentShopsRepository extends Mock implements RecentShopsRepository {}

void main() {
  late ClearRecentShopsUseCase useCase;
  late MockRecentShopsRepository mockRepository;

  setUp(() {
    mockRepository = MockRecentShopsRepository();
    useCase = ClearRecentShopsUseCase(mockRepository);
  });

  group('ClearRecentShopsUseCase', () {
    test('should clear recent shops via repository', () async {
      when(() => mockRepository.clearRecentShops())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.clearRecentShops()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.clearRecentShops())
          .thenAnswer((_) async => const Left(CacheFailure('Error')));

      final result = await useCase();

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
