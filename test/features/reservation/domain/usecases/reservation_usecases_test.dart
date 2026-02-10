import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/create_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_dates_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_slots_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
  });

  final tReservation = Reservation(
    id: 'res-1',
    shopId: 'shop-1',
    memberId: 'member-1',
    treatmentId: 'treatment-1',
    reservationDate: '2025-06-15',
    startTime: '14:00',
    endTime: '15:00',
    status: ReservationStatus.pending,
    createdAt: DateTime(2025, 6, 10),
    updatedAt: DateTime(2025, 6, 10),
  );

  group('CreateReservationUseCase', () {
    late CreateReservationUseCase useCase;

    setUp(() {
      useCase = CreateReservationUseCase(repository: mockRepository);
    });

    const tParams = CreateReservationParams(
      shopId: 'shop-1',
      treatmentId: 'treatment-1',
      reservationDate: '2025-06-15',
      startTime: '14:00',
      memo: '메모',
    );

    test('should return Reservation when repository call is successful',
        () async {
      when(() => mockRepository.createReservation(tParams))
          .thenAnswer((_) async => Right(tReservation));

      final result = await useCase(tParams);

      expect(result, Right(tReservation));
      verify(() => mockRepository.createReservation(tParams)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.createReservation(tParams))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(tParams);

      expect(result, isA<Left<Failure, Reservation>>());
    });
  });

  group('GetMyReservationsUseCase', () {
    late GetMyReservationsUseCase useCase;

    setUp(() {
      useCase = GetMyReservationsUseCase(repository: mockRepository);
    });

    test('should return list of Reservation when repository call is successful',
        () async {
      when(() => mockRepository.getMyReservations())
          .thenAnswer((_) async => Right([tReservation]));

      final result = await useCase();

      expect(result, isA<Right<Failure, List<Reservation>>>());
      verify(() => mockRepository.getMyReservations()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getMyReservations())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase();

      expect(result, isA<Left<Failure, List<Reservation>>>());
    });
  });

  group('CancelReservationUseCase', () {
    late CancelReservationUseCase useCase;

    setUp(() {
      useCase = CancelReservationUseCase(repository: mockRepository);
    });

    const tReservationId = 'res-1';

    test('should return Reservation when repository call is successful',
        () async {
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

      when(() => mockRepository.cancelReservation(tReservationId))
          .thenAnswer((_) async => Right(cancelledReservation));

      final result = await useCase(tReservationId);

      expect(result, Right(cancelledReservation));
      verify(() => mockRepository.cancelReservation(tReservationId)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.cancelReservation(tReservationId))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(tReservationId);

      expect(result, isA<Left<Failure, Reservation>>());
    });
  });

  group('GetAvailableDatesUseCase', () {
    late GetAvailableDatesUseCase useCase;

    setUp(() {
      useCase = GetAvailableDatesUseCase(repository: mockRepository);
    });

    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tYearMonth = '2025-06';

    test('should return list of date strings when repository call is successful',
        () async {
      when(() =>
              mockRepository.getAvailableDates(tShopId, tTreatmentId, tYearMonth))
          .thenAnswer(
              (_) async => const Right(['2025-06-15', '2025-06-16']));

      final result = await useCase(tShopId, tTreatmentId, tYearMonth);

      expect(result, isA<Right<Failure, List<String>>>());
      verify(() =>
              mockRepository.getAvailableDates(tShopId, tTreatmentId, tYearMonth))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() =>
              mockRepository.getAvailableDates(tShopId, tTreatmentId, tYearMonth))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(tShopId, tTreatmentId, tYearMonth);

      expect(result, isA<Left<Failure, List<String>>>());
    });
  });

  group('GetAvailableSlotsUseCase', () {
    late GetAvailableSlotsUseCase useCase;

    setUp(() {
      useCase = GetAvailableSlotsUseCase(repository: mockRepository);
    });

    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tDate = '2025-06-15';

    test('should return AvailableSlotsResult when repository call is successful',
        () async {
      const tResult = AvailableSlotsResult(
        date: '2025-06-15',
        openTime: '10:00',
        closeTime: '20:00',
        slots: [AvailableSlot(startTime: '10:00', available: true)],
      );

      when(() =>
              mockRepository.getAvailableSlots(tShopId, tTreatmentId, tDate))
          .thenAnswer((_) async => const Right(tResult));

      final result = await useCase(tShopId, tTreatmentId, tDate);

      expect(result, isA<Right<Failure, AvailableSlotsResult>>());
      verify(() =>
              mockRepository.getAvailableSlots(tShopId, tTreatmentId, tDate))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() =>
              mockRepository.getAvailableSlots(tShopId, tTreatmentId, tDate))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase(tShopId, tTreatmentId, tDate);

      expect(result, isA<Left<Failure, AvailableSlotsResult>>());
    });
  });
}
