import 'package:equatable/equatable.dart';

class CreateReservationParams extends Equatable {
  final String shopId;
  final String treatmentId;
  final String reservationDate;
  final String startTime;
  final String? memo;

  const CreateReservationParams({
    required this.shopId,
    required this.treatmentId,
    required this.reservationDate,
    required this.startTime,
    this.memo,
  });

  @override
  List<Object?> get props => [shopId, treatmentId, reservationDate, startTime, memo];
}
