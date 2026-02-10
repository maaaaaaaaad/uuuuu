import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/current_reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

void main() {
  late MockGetMyReservationsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetMyReservationsUseCase();
  });

  String todayString() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String tomorrowString() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final y = tomorrow.year;
    final m = tomorrow.month.toString().padLeft(2, '0');
    final d = tomorrow.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String dayAfterTomorrowString() {
    final date = DateTime.now().add(const Duration(days: 2));
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Reservation makeReservation({
    String id = 'r-1',
    String? reservationDate,
    String startTime = '14:00',
    String endTime = '15:00',
    ReservationStatus status = ReservationStatus.confirmed,
    String? shopName = '젤로네일',
    String? treatmentName = '젤네일',
  }) {
    return Reservation(
      id: id,
      shopId: 'shop-1',
      memberId: 'member-1',
      treatmentId: 'treatment-1',
      shopName: shopName,
      treatmentName: treatmentName,
      treatmentPrice: 30000,
      treatmentDuration: 60,
      reservationDate: reservationDate ?? todayString(),
      startTime: startTime,
      endTime: endTime,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getMyReservationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  }

  group('CurrentReservationNotifier', () {
    test('should have initial empty state', () {
      when(() => mockUseCase()).thenAnswer((_) async => const Right([]));
      final container = createContainer();

      final state = container.read(currentReservationNotifierProvider);

      expect(state.todayReservation, isNull);
      expect(state.upcomingReservation, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);

      container.dispose();
    });

    test('should set today reservation when confirmed reservation exists for today',
        () async {
      final todayReservation = makeReservation(
        reservationDate: todayString(),
        startTime: '23:59',
        endTime: '23:59',
      );
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([todayReservation]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.todayReservation, todayReservation);
      expect(state.upcomingReservation, isNull);
      expect(state.isLoading, false);

      container.dispose();
    });

    test('should set upcoming reservation when confirmed reservation exists for future date',
        () async {
      final upcomingReservation = makeReservation(
        reservationDate: tomorrowString(),
      );
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([upcomingReservation]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.todayReservation, isNull);
      expect(state.upcomingReservation, upcomingReservation);
      expect(state.isLoading, false);

      container.dispose();
    });

    test('should set both today and upcoming reservations', () async {
      final todayRes = makeReservation(
        id: 'r-today',
        reservationDate: todayString(),
        startTime: '23:59',
        endTime: '23:59',
      );
      final upcomingRes = makeReservation(
        id: 'r-upcoming',
        reservationDate: tomorrowString(),
      );
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([todayRes, upcomingRes]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.todayReservation, todayRes);
      expect(state.upcomingReservation, upcomingRes);

      container.dispose();
    });

    test('should ignore non-confirmed reservations', () async {
      final pendingRes = makeReservation(
        status: ReservationStatus.pending,
        reservationDate: todayString(),
      );
      final cancelledRes = makeReservation(
        id: 'r-cancelled',
        status: ReservationStatus.cancelled,
        reservationDate: tomorrowString(),
      );
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([pendingRes, cancelledRes]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.todayReservation, isNull);
      expect(state.upcomingReservation, isNull);

      container.dispose();
    });

    test('should select nearest upcoming reservation', () async {
      final tomorrow = makeReservation(
        id: 'r-tomorrow',
        reservationDate: tomorrowString(),
      );
      final dayAfter = makeReservation(
        id: 'r-dayafter',
        reservationDate: dayAfterTomorrowString(),
      );
      when(() => mockUseCase())
          .thenAnswer((_) async => Right([dayAfter, tomorrow]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.upcomingReservation!.id, 'r-tomorrow');

      container.dispose();
    });

    test('should handle error', () async {
      when(() => mockUseCase()).thenAnswer(
        (_) async => const Left(ServerFailure('네트워크 오류')),
      );
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      await notifier.load();

      final state = container.read(currentReservationNotifierProvider);
      expect(state.error, '네트워크 오류');
      expect(state.todayReservation, isNull);
      expect(state.upcomingReservation, isNull);

      container.dispose();
    });

    test('should set loading state during load', () async {
      when(() => mockUseCase()).thenAnswer((_) async => const Right([]));
      final container = createContainer();
      final notifier =
          container.read(currentReservationNotifierProvider.notifier);

      final states = <CurrentReservationState>[];
      container.listen(
        currentReservationNotifierProvider,
        (_, next) => states.add(next),
      );

      await notifier.load();

      expect(states.any((s) => s.isLoading), true);

      container.dispose();
    });
  });
}
