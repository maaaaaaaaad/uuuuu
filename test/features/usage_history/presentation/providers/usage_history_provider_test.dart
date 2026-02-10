import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/usecases/get_usage_history_usecase.dart';
import 'package:jellomark/features/usage_history/presentation/providers/usage_history_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUsageHistoryUseCase extends Mock
    implements GetUsageHistoryUseCase {}

void main() {
  late MockGetUsageHistoryUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetUsageHistoryUseCase();
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

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getUsageHistoryUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('UsageHistoryNotifier', () {
    test('should have initial empty state', () {
      when(() => mockUseCase()).thenAnswer((_) async => const Right([]));
      final container = createContainer();

      final state = container.read(usageHistoryNotifierProvider);

      expect(state.histories, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);

      container.dispose();
    });

    test('should load usage history successfully', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([tUsageHistory]));
      final container = createContainer();
      final notifier =
          container.read(usageHistoryNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(usageHistoryNotifierProvider);
      expect(state.histories.length, 1);
      expect(state.histories.first.id, 'uh-1');
      expect(state.isLoading, false);

      container.dispose();
    });

    test('should handle load failure', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('오류')));
      final container = createContainer();
      final notifier =
          container.read(usageHistoryNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(usageHistoryNotifierProvider);
      expect(state.error, '오류');
      expect(state.histories, isEmpty);

      container.dispose();
    });

    test('should set loading state during load', () async {
      when(() => mockUseCase()).thenAnswer((_) async => const Right([]));
      final container = createContainer();
      final notifier =
          container.read(usageHistoryNotifierProvider.notifier);

      final states = <UsageHistoryState>[];
      container.listen(
        usageHistoryNotifierProvider,
        (_, next) => states.add(next),
      );

      await notifier.load();

      expect(states.any((s) => s.isLoading), true);

      container.dispose();
    });
  });
}
