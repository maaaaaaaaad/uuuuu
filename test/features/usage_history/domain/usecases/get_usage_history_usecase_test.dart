import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/repositories/usage_history_repository.dart';
import 'package:jellomark/features/usage_history/domain/usecases/get_usage_history_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockUsageHistoryRepository extends Mock
    implements UsageHistoryRepository {}

void main() {
  late MockUsageHistoryRepository mockRepository;
  late GetUsageHistoryUseCase useCase;

  setUp(() {
    mockRepository = MockUsageHistoryRepository();
    useCase = GetUsageHistoryUseCase(repository: mockRepository);
  });

  final tUsageHistory = UsageHistory(
    id: 'uh-1',
    memberId: 'member-1',
    shopId: 'shop-1',
    reservationId: 'reservation-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    completedAt: DateTime(2026, 1, 15, 14, 0),
    createdAt: DateTime(2026, 1, 15, 14, 0),
  );

  group('GetUsageHistoryUseCase', () {
    test('should return list of UsageHistory from repository', () async {
      when(() => mockRepository.getMyUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory]));

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (histories) => expect(histories.length, 1),
      );
      verify(() => mockRepository.getMyUsageHistory()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getMyUsageHistory())
          .thenAnswer((_) async => const Left(ServerFailure('오류')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });
  });
}
