import 'package:equatable/equatable.dart';

class UsageHistory extends Equatable {
  final String id;
  final String memberId;
  final String shopId;
  final String reservationId;
  final String shopName;
  final String treatmentName;
  final int treatmentPrice;
  final int treatmentDuration;
  final DateTime completedAt;
  final DateTime createdAt;

  const UsageHistory({
    required this.id,
    required this.memberId,
    required this.shopId,
    required this.reservationId,
    required this.shopName,
    required this.treatmentName,
    required this.treatmentPrice,
    required this.treatmentDuration,
    required this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        memberId,
        shopId,
        reservationId,
        shopName,
        treatmentName,
        treatmentPrice,
        treatmentDuration,
        completedAt,
        createdAt,
      ];
}
