import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';

class CreateReservationRequest {
  final String shopId;
  final String treatmentId;
  final String reservationDate;
  final String startTime;
  final String? memo;

  const CreateReservationRequest({
    required this.shopId,
    required this.treatmentId,
    required this.reservationDate,
    required this.startTime,
    this.memo,
  });

  factory CreateReservationRequest.fromParams(CreateReservationParams params) {
    return CreateReservationRequest(
      shopId: params.shopId,
      treatmentId: params.treatmentId,
      reservationDate: params.reservationDate,
      startTime: params.startTime,
      memo: params.memo,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'shopId': shopId,
      'treatmentId': treatmentId,
      'reservationDate': reservationDate,
      'startTime': startTime,
    };
    if (memo != null) {
      json['memo'] = memo;
    }
    return json;
  }
}
