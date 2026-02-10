import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/reservation/data/models/available_dates_model.dart';
import 'package:jellomark/features/reservation/data/models/available_slots_result_model.dart';
import 'package:jellomark/features/reservation/data/models/create_reservation_request.dart';
import 'package:jellomark/features/reservation/data/models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<ReservationModel> createReservation(CreateReservationRequest request);
  Future<List<ReservationModel>> getMyReservations();
  Future<ReservationModel> cancelReservation(String reservationId);
  Future<AvailableDatesModel> getAvailableDates(
      String shopId, String treatmentId, String yearMonth);
  Future<AvailableSlotsResultModel> getAvailableSlots(
      String shopId, String treatmentId, String date);
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final ApiClient _apiClient;

  ReservationRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ReservationModel> createReservation(
      CreateReservationRequest request) async {
    final response = await _apiClient.post(
      '/api/reservations',
      data: request.toJson(),
    );

    return ReservationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    final response = await _apiClient.get('/api/reservations/me');

    return (response.data as List<dynamic>)
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReservationModel> cancelReservation(String reservationId) async {
    final response = await _apiClient.patch(
      '/api/reservations/$reservationId/cancel',
    );

    return ReservationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AvailableDatesModel> getAvailableDates(
      String shopId, String treatmentId, String yearMonth) async {
    final response = await _apiClient.get(
      '/api/beautishops/$shopId/available-dates',
      queryParameters: {
        'treatmentId': treatmentId,
        'yearMonth': yearMonth,
      },
    );

    return AvailableDatesModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AvailableSlotsResultModel> getAvailableSlots(
      String shopId, String treatmentId, String date) async {
    final response = await _apiClient.get(
      '/api/beautishops/$shopId/available-slots',
      queryParameters: {
        'treatmentId': treatmentId,
        'date': date,
      },
    );

    return AvailableSlotsResultModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
