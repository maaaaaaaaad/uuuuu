import 'package:equatable/equatable.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

class ReservationModel extends Equatable {
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
  final String status;
  final String? memo;
  final String? rejectionReason;
  final String createdAt;
  final String updatedAt;

  const ReservationModel({
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

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      memberId: json['memberId'] as String,
      treatmentId: json['treatmentId'] as String,
      shopName: json['shopName'] as String?,
      treatmentName: json['treatmentName'] as String?,
      treatmentPrice: json['treatmentPrice'] as int?,
      treatmentDuration: json['treatmentDuration'] as int?,
      memberNickname: json['memberNickname'] as String?,
      reservationDate: json['reservationDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
      memo: json['memo'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'memberId': memberId,
      'treatmentId': treatmentId,
      'shopName': shopName,
      'treatmentName': treatmentName,
      'treatmentPrice': treatmentPrice,
      'treatmentDuration': treatmentDuration,
      'memberNickname': memberNickname,
      'reservationDate': reservationDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'memo': memo,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Reservation toEntity() {
    return Reservation(
      id: id,
      shopId: shopId,
      memberId: memberId,
      treatmentId: treatmentId,
      shopName: shopName,
      treatmentName: treatmentName,
      treatmentPrice: treatmentPrice,
      treatmentDuration: treatmentDuration,
      memberNickname: memberNickname,
      reservationDate: reservationDate,
      startTime: startTime,
      endTime: endTime,
      status: ReservationStatus.fromString(status),
      memo: memo,
      rejectionReason: rejectionReason,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

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
