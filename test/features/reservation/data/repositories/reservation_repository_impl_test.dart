import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:jellomark/features/reservation/data/models/available_dates_model.dart';
import 'package:jellomark/features/reservation/data/models/available_slot_model.dart';
import 'package:jellomark/features/reservation/data/models/available_slots_result_model.dart';
import 'package:jellomark/features/reservation/data/models/create_reservation_request.dart';
import 'package:jellomark/features/reservation/data/models/reservation_model.dart';
import 'package:jellomark/features/reservation/data/repositories/reservation_repository_impl.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRemoteDataSource extends Mock
    implements ReservationRemoteDataSource {}

void main() {
  late ReservationRepositoryImpl repository;
  late MockReservationRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockReservationRemoteDataSource();
    repository = ReservationRepositoryImpl(remoteDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const CreateReservationRequest(
      shopId: '',
      treatmentId: '',
      reservationDate: '',
      startTime: '',
    ));
  });

  const tReservationModel = ReservationModel(
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
    status: 'PENDING',
    createdAt: '2025-06-10T10:30:00Z',
    updatedAt: '2025-06-10T10:30:00Z',
  );

  group('createReservation', () {
    const tParams = CreateReservationParams(
      shopId: 'shop-1',
      treatmentId: 'treatment-1',
      reservationDate: '2025-06-15',
      startTime: '14:00',
      memo: '메모',
    );

    test('should return Reservation when data source call is successful',
        () async {
      when(() => mockDataSource.createReservation(any()))
          .thenAnswer((_) async => tReservationModel);

      final result = await repository.createReservation(tParams);

      expect(result, isA<Right<Failure, Reservation>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (reservation) {
          expect(reservation.id, 'res-1');
          expect(reservation.shopName, '젤로네일');
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.createReservation(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.createReservation(tParams);

      expect(result, isA<Left<Failure, Reservation>>());
    });
  });

  group('getMyReservations', () {
    test('should return list of Reservation when data source call is successful',
        () async {
      when(() => mockDataSource.getMyReservations())
          .thenAnswer((_) async => [tReservationModel]);

      final result = await repository.getMyReservations();

      expect(result, isA<Right<Failure, List<Reservation>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (reservations) {
          expect(reservations.length, 1);
          expect(reservations.first.id, 'res-1');
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.getMyReservations()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.getMyReservations();

      expect(result, isA<Left<Failure, List<Reservation>>>());
    });
  });

  group('cancelReservation', () {
    const tReservationId = 'res-1';

    test('should return Reservation when data source call is successful',
        () async {
      const cancelledModel = ReservationModel(
        id: 'res-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: 'CANCELLED',
        createdAt: '2025-06-10T10:30:00Z',
        updatedAt: '2025-06-10T11:00:00Z',
      );

      when(() => mockDataSource.cancelReservation(tReservationId))
          .thenAnswer((_) async => cancelledModel);

      final result = await repository.cancelReservation(tReservationId);

      expect(result, isA<Right<Failure, Reservation>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (reservation) {
          expect(reservation.status.name, 'cancelled');
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.cancelReservation(tReservationId)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.cancelReservation(tReservationId);

      expect(result, isA<Left<Failure, Reservation>>());
    });
  });

  group('getAvailableDates', () {
    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tYearMonth = '2025-06';

    test('should return list of date strings when data source call is successful',
        () async {
      when(() => mockDataSource.getAvailableDates(
              tShopId, tTreatmentId, tYearMonth))
          .thenAnswer((_) async => const AvailableDatesModel(
                availableDates: ['2025-06-15', '2025-06-16'],
              ));

      final result =
          await repository.getAvailableDates(tShopId, tTreatmentId, tYearMonth);

      expect(result, isA<Right<Failure, List<String>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (dates) {
          expect(dates.length, 2);
          expect(dates[0], '2025-06-15');
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() => mockDataSource.getAvailableDates(
              tShopId, tTreatmentId, tYearMonth))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Server error',
      ));

      final result =
          await repository.getAvailableDates(tShopId, tTreatmentId, tYearMonth);

      expect(result, isA<Left<Failure, List<String>>>());
    });
  });

  group('getAvailableSlots', () {
    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tDate = '2025-06-15';

    test('should return AvailableSlotsResult when data source call is successful',
        () async {
      when(() =>
              mockDataSource.getAvailableSlots(tShopId, tTreatmentId, tDate))
          .thenAnswer((_) async => const AvailableSlotsResultModel(
                date: '2025-06-15',
                openTime: '10:00',
                closeTime: '20:00',
                slots: [
                  AvailableSlotModel(startTime: '10:00', available: true),
                ],
              ));

      final result =
          await repository.getAvailableSlots(tShopId, tTreatmentId, tDate);

      expect(result, isA<Right<Failure, AvailableSlotsResult>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (slotsResult) {
          expect(slotsResult.date, '2025-06-15');
          expect(slotsResult.slots.length, 1);
          expect(slotsResult.slots[0].available, true);
        },
      );
    });

    test('should return ServerFailure when data source throws DioException',
        () async {
      when(() =>
              mockDataSource.getAvailableSlots(tShopId, tTreatmentId, tDate))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Server error',
      ));

      final result =
          await repository.getAvailableSlots(tShopId, tTreatmentId, tDate);

      expect(result, isA<Left<Failure, AvailableSlotsResult>>());
    });
  });
}
