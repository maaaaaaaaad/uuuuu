import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:jellomark/features/reservation/data/models/available_dates_model.dart';
import 'package:jellomark/features/reservation/data/models/available_slots_result_model.dart';
import 'package:jellomark/features/reservation/data/models/create_reservation_request.dart';
import 'package:jellomark/features/reservation/data/models/reservation_model.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ReservationRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ReservationRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  final tReservationJson = {
    'id': 'res-1',
    'shopId': 'shop-1',
    'memberId': 'member-1',
    'treatmentId': 'treatment-1',
    'shopName': '젤로네일',
    'treatmentName': '젤네일',
    'treatmentPrice': 30000,
    'treatmentDuration': 60,
    'memberNickname': '홍길동',
    'reservationDate': '2025-06-15',
    'startTime': '14:00',
    'endTime': '15:00',
    'status': 'PENDING',
    'memo': '첫 방문',
    'rejectionReason': null,
    'createdAt': '2025-06-10T10:30:00Z',
    'updatedAt': '2025-06-10T10:30:00Z',
  };

  group('createReservation', () {
    const tRequest = CreateReservationRequest(
      shopId: 'shop-1',
      treatmentId: 'treatment-1',
      reservationDate: '2025-06-15',
      startTime: '14:00',
      memo: '첫 방문',
    );

    test('should return ReservationModel when API call is successful', () async {
      when(() => mockApiClient.post(
            '/api/reservations',
            data: tRequest.toJson(),
          )).thenAnswer(
        (_) async => Response(
          data: tReservationJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.createReservation(tRequest);

      expect(result, isA<ReservationModel>());
      expect(result.id, 'res-1');
      expect(result.status, 'PENDING');
      verify(() => mockApiClient.post(
            '/api/reservations',
            data: tRequest.toJson(),
          )).called(1);
    });
  });

  group('getMyReservations', () {
    test('should return list of ReservationModel when API call is successful',
        () async {
      when(() => mockApiClient.get('/api/reservations/me')).thenAnswer(
        (_) async => Response(
          data: [tReservationJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getMyReservations();

      expect(result, isA<List<ReservationModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'res-1');
      verify(() => mockApiClient.get('/api/reservations/me')).called(1);
    });

    test('should return empty list when no reservations', () async {
      when(() => mockApiClient.get('/api/reservations/me')).thenAnswer(
        (_) async => Response(
          data: <dynamic>[],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getMyReservations();

      expect(result, isEmpty);
    });
  });

  group('cancelReservation', () {
    const tReservationId = 'res-1';

    test('should return ReservationModel when API call is successful', () async {
      final cancelledJson = Map<String, dynamic>.from(tReservationJson);
      cancelledJson['status'] = 'CANCELLED';

      when(() => mockApiClient.patch(
            '/api/reservations/$tReservationId/cancel',
          )).thenAnswer(
        (_) async => Response(
          data: cancelledJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.cancelReservation(tReservationId);

      expect(result, isA<ReservationModel>());
      expect(result.status, 'CANCELLED');
      verify(() => mockApiClient.patch(
            '/api/reservations/$tReservationId/cancel',
          )).called(1);
    });
  });

  group('getAvailableDates', () {
    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tYearMonth = '2025-06';

    test('should return AvailableDatesModel when API call is successful',
        () async {
      when(() => mockApiClient.get(
            '/api/beautishops/$tShopId/available-dates',
            queryParameters: {
              'treatmentId': tTreatmentId,
              'yearMonth': tYearMonth,
            },
          )).thenAnswer(
        (_) async => Response(
          data: {
            'availableDates': ['2025-06-15', '2025-06-16'],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getAvailableDates(
          tShopId, tTreatmentId, tYearMonth);

      expect(result, isA<AvailableDatesModel>());
      expect(result.availableDates.length, 2);
      expect(result.availableDates[0], '2025-06-15');
    });
  });

  group('getAvailableSlots', () {
    const tShopId = 'shop-1';
    const tTreatmentId = 'treatment-1';
    const tDate = '2025-06-15';

    test('should return AvailableSlotsResultModel when API call is successful',
        () async {
      when(() => mockApiClient.get(
            '/api/beautishops/$tShopId/available-slots',
            queryParameters: {
              'treatmentId': tTreatmentId,
              'date': tDate,
            },
          )).thenAnswer(
        (_) async => Response(
          data: {
            'date': '2025-06-15',
            'openTime': '10:00',
            'closeTime': '20:00',
            'slots': [
              {'startTime': '10:00', 'available': true},
              {'startTime': '10:30', 'available': false},
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result =
          await dataSource.getAvailableSlots(tShopId, tTreatmentId, tDate);

      expect(result, isA<AvailableSlotsResultModel>());
      expect(result.date, '2025-06-15');
      expect(result.slots.length, 2);
      expect(result.slots[0].available, true);
    });
  });
}
