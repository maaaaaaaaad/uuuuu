import 'package:equatable/equatable.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

class Reservation extends Equatable {
  final String id;
  final String shopId;
  final String memberId;
  final String treatmentId;
  final String? shopName;
  final String? treatmentName;
  final int? treatmentPrice;
  final int? treatmentDuration;
  final String? memberNickname;
  final String reservationDate;
  final String startTime;
  final String endTime;
  final ReservationStatus status;
  final String? memo;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.shopId,
    required this.memberId,
    required this.treatmentId,
    this.shopName,
    this.treatmentName,
    this.treatmentPrice,
    this.treatmentDuration,
    this.memberNickname,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.memo,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        shopId,
        memberId,
        treatmentId,
        shopName,
        treatmentName,
        treatmentPrice,
        treatmentDuration,
        memberNickname,
        reservationDate,
        startTime,
        endTime,
        status,
        memo,
        rejectionReason,
        createdAt,
        updatedAt,
      ];
}
