import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_detail_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetReservationUseCase extends Mock
    implements GetReservationUseCase {}

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  late MockGetReservationUseCase mockGetReservationUseCase;
  late MockGetMyReservationsUseCase mockGetMyReservationsUseCase;

  setUp(() {
    mockGetReservationUseCase = MockGetReservationUseCase();
    mockGetMyReservationsUseCase = MockGetMyReservationsUseCase();
  });

  final tReservation = Reservation(
    id: 'res-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.completed,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  ProviderContainer createContainer({
    List<Reservation> cachedReservations = const [],
  }) {
    when(() => mockGetMyReservationsUseCase())
        .thenAnswer((_) async => Right(cachedReservations));

    return ProviderContainer(
      overrides: [
        getReservationUseCaseProvider
            .overrideWithValue(mockGetReservationUseCase),
        getMyReservationsUseCaseProvider
            .overrideWithValue(mockGetMyReservationsUseCase),
      ],
    );
  }

  group('ReservationDetailNotifier', () {
    test(
        'should use cached reservation when available in myReservationsNotifier',
        () async {
      final container = createContainer(cachedReservations: [tReservation]);
      addTearDown(container.dispose);

      final myNotifier =
          container.read(myReservationsNotifierProvider.notifier);
      await myNotifier.loadReservations();

      final listener = Listener<ReservationDetailState>();
      container.listen(
        reservationDetailNotifierProvider('res-1'),
        listener.call,
        fireImmediately: true,
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state =
          container.read(reservationDetailNotifierProvider('res-1'));
      expect(state.reservation, tReservation);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      verifyNever(() => mockGetReservationUseCase(any()));
    });

    test('should fetch from API when not in cache', () async {
      when(() => mockGetReservationUseCase('res-1'))
          .thenAnswer((_) async => Right(tReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final listener = Listener<ReservationDetailState>();
      container.listen(
        reservationDetailNotifierProvider('res-1'),
        listener.call,
        fireImmediately: true,
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state =
          container.read(reservationDetailNotifierProvider('res-1'));
      expect(state.reservation, tReservation);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      verify(() => mockGetReservationUseCase('res-1')).called(1);
    });

    test('should set error when API call fails', () async {
      when(() => mockGetReservationUseCase('res-1'))
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final listener = Listener<ReservationDetailState>();
      container.listen(
        reservationDetailNotifierProvider('res-1'),
        listener.call,
        fireImmediately: true,
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state =
          container.read(reservationDetailNotifierProvider('res-1'));
      expect(state.reservation, isNull);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });
  });

  group('ReservationDetailState', () {
    test('should have default values', () {
      const state = ReservationDetailState();

      expect(state.reservation, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith should update fields', () {
      const state = ReservationDetailState();
      final updated = state.copyWith(
        reservation: tReservation,
        isLoading: true,
        error: 'error',
      );

      expect(updated.reservation, tReservation);
      expect(updated.isLoading, true);
      expect(updated.error, 'error');
    });

    test('copyWith should preserve fields when not specified', () {
      final state = ReservationDetailState(reservation: tReservation);
      final updated = state.copyWith(isLoading: true);

      expect(updated.reservation, tReservation);
      expect(updated.isLoading, true);
      expect(updated.error, isNull);
    });
  });
}
