import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_dates_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_slots_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/available_slots_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAvailableDatesUseCase extends Mock
    implements GetAvailableDatesUseCase {}

class MockGetAvailableSlotsUseCase extends Mock
    implements GetAvailableSlotsUseCase {}

void main() {
  late MockGetAvailableDatesUseCase mockDatesUseCase;
  late MockGetAvailableSlotsUseCase mockSlotsUseCase;

  setUp(() {
    mockDatesUseCase = MockGetAvailableDatesUseCase();
    mockSlotsUseCase = MockGetAvailableSlotsUseCase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getAvailableDatesUseCaseProvider
            .overrideWithValue(mockDatesUseCase),
        getAvailableSlotsUseCaseProvider
            .overrideWithValue(mockSlotsUseCase),
      ],
    );
  }

  group('AvailableDatesNotifier', () {
    test('should load available dates successfully', () async {
      when(() => mockDatesUseCase('shop-1', 'treatment-1', '2025-06'))
          .thenAnswer(
              (_) async => const Right(['2025-06-15', '2025-06-16']));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableDatesNotifierProvider.notifier);

      await notifier.loadDates('shop-1', 'treatment-1', '2025-06');

      final state = container.read(availableDatesNotifierProvider);
      expect(state.dates.length, 2);
      expect(state.dates[0], '2025-06-15');
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      when(() => mockDatesUseCase('shop-1', 'treatment-1', '2025-06'))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableDatesNotifierProvider.notifier);

      await notifier.loadDates('shop-1', 'treatment-1', '2025-06');

      final state = container.read(availableDatesNotifierProvider);
      expect(state.dates, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });

    test('should reset state', () async {
      when(() => mockDatesUseCase('shop-1', 'treatment-1', '2025-06'))
          .thenAnswer(
              (_) async => const Right(['2025-06-15']));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableDatesNotifierProvider.notifier);

      await notifier.loadDates('shop-1', 'treatment-1', '2025-06');
      notifier.reset();

      final state = container.read(availableDatesNotifierProvider);
      expect(state.dates, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });

  group('AvailableSlotsNotifier', () {
    const tSlotsResult = AvailableSlotsResult(
      date: '2025-06-15',
      openTime: '10:00',
      closeTime: '20:00',
      slots: [
        AvailableSlot(startTime: '10:00', available: true),
        AvailableSlot(startTime: '10:30', available: false),
        AvailableSlot(startTime: '11:00', available: true),
      ],
    );

    test('should load available slots successfully', () async {
      when(() => mockSlotsUseCase('shop-1', 'treatment-1', '2025-06-15'))
          .thenAnswer((_) async => const Right(tSlotsResult));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableSlotsNotifierProvider.notifier);

      await notifier.loadSlots('shop-1', 'treatment-1', '2025-06-15');

      final state = container.read(availableSlotsNotifierProvider);
      expect(state.slots.length, 3);
      expect(state.openTime, '10:00');
      expect(state.closeTime, '20:00');
      expect(state.slots[0].available, true);
      expect(state.slots[1].available, false);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      when(() => mockSlotsUseCase('shop-1', 'treatment-1', '2025-06-15'))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableSlotsNotifierProvider.notifier);

      await notifier.loadSlots('shop-1', 'treatment-1', '2025-06-15');

      final state = container.read(availableSlotsNotifierProvider);
      expect(state.slots, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });

    test('should reset state', () async {
      when(() => mockSlotsUseCase('shop-1', 'treatment-1', '2025-06-15'))
          .thenAnswer((_) async => const Right(tSlotsResult));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(availableSlotsNotifierProvider.notifier);

      await notifier.loadSlots('shop-1', 'treatment-1', '2025-06-15');
      notifier.reset();

      final state = container.read(availableSlotsNotifierProvider);
      expect(state.slots, isEmpty);
      expect(state.openTime, isNull);
      expect(state.closeTime, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });
}
