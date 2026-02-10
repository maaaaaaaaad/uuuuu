import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/create_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateReservationUseCase extends Mock
    implements CreateReservationUseCase {}

class MockGetMyReservationsUseCase extends Mock
    implements GetMyReservationsUseCase {}

class MockCancelReservationUseCase extends Mock
    implements CancelReservationUseCase {}

void main() {
  late MockCreateReservationUseCase mockCreateUseCase;
  late MockGetMyReservationsUseCase mockGetUseCase;
  late MockCancelReservationUseCase mockCancelUseCase;

  setUp(() {
    mockCreateUseCase = MockCreateReservationUseCase();
    mockGetUseCase = MockGetMyReservationsUseCase();
    mockCancelUseCase = MockCancelReservationUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const CreateReservationParams(
      shopId: '',
      treatmentId: '',
      reservationDate: '',
      startTime: '',
    ));
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
    status: ReservationStatus.pending,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  final tConfirmedReservation = Reservation(
    id: 'res-2',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    reservationDate: '2025-06-16',
    startTime: '10:00',
    endTime: '11:00',
    status: ReservationStatus.confirmed,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        createReservationUseCaseProvider
            .overrideWithValue(mockCreateUseCase),
        getMyReservationsUseCaseProvider
            .overrideWithValue(mockGetUseCase),
        cancelReservationUseCaseProvider
            .overrideWithValue(mockCancelUseCase),
      ],
    );
  }

  group('MyReservationsNotifier', () {
    test('should load reservations successfully', () async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation, tConfirmedReservation]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(myReservationsNotifierProvider.notifier);

      await notifier.loadReservations();

      final state = container.read(myReservationsNotifierProvider);
      expect(state.reservations.length, 2);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle load failure', () async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(myReservationsNotifierProvider.notifier);

      await notifier.loadReservations();

      final state = container.read(myReservationsNotifierProvider);
      expect(state.reservations, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, '서버 오류');
    });

    test('should filter by status', () async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation, tConfirmedReservation]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(myReservationsNotifierProvider.notifier);

      await notifier.loadReservations();
      notifier.filterByStatus(ReservationStatus.pending);

      final state = container.read(myReservationsNotifierProvider);
      expect(state.filterStatus, ReservationStatus.pending);
      expect(state.filteredReservations.length, 1);
      expect(
          state.filteredReservations.first.status, ReservationStatus.pending);
    });

    test('should clear filter when null is passed', () async {
      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation, tConfirmedReservation]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(myReservationsNotifierProvider.notifier);

      await notifier.loadReservations();
      notifier.filterByStatus(ReservationStatus.pending);
      notifier.filterByStatus(null);

      final state = container.read(myReservationsNotifierProvider);
      expect(state.filterStatus, isNull);
      expect(state.filteredReservations.length, 2);
    });

    test('should cancel reservation and reload', () async {
      final cancelledReservation = Reservation(
        id: 'res-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.cancelled,
        createdAt: DateTime(2025, 6, 10),
        updatedAt: DateTime(2025, 6, 10),
      );

      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([tReservation]));
      when(() => mockCancelUseCase('res-1'))
          .thenAnswer((_) async => Right(cancelledReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(myReservationsNotifierProvider.notifier);

      await notifier.loadReservations();

      when(() => mockGetUseCase())
          .thenAnswer((_) async => Right([cancelledReservation]));

      await notifier.cancelReservation('res-1');

      final state = container.read(myReservationsNotifierProvider);
      expect(state.reservations.first.status, ReservationStatus.cancelled);
    });
  });

  group('CreateReservationNotifier', () {
    const tParams = CreateReservationParams(
      shopId: 'shop-1',
      treatmentId: 'treatment-1',
      reservationDate: '2025-06-15',
      startTime: '14:00',
    );

    test('should create reservation successfully', () async {
      when(() => mockCreateUseCase(any()))
          .thenAnswer((_) async => Right(tReservation));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(createReservationNotifierProvider.notifier);

      await notifier.createReservation(tParams);

      final state = container.read(createReservationNotifierProvider);
      expect(state.isSuccess, true);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should handle create failure', () async {
      when(() => mockCreateUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('시간이 겹칩니다')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(createReservationNotifierProvider.notifier);

      await notifier.createReservation(tParams);

      final state = container.read(createReservationNotifierProvider);
      expect(state.isSuccess, false);
      expect(state.isLoading, false);
      expect(state.error, '시간이 겹칩니다');
    });
  });
}
