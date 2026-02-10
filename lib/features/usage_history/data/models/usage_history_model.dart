import 'package:equatable/equatable.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';

class UsageHistoryModel extends Equatable {
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

  const UsageHistoryModel({
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

  factory UsageHistoryModel.fromJson(Map<String, dynamic> json) {
    return UsageHistoryModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      shopId: json['shopId'] as String,
      reservationId: json['reservationId'] as String,
      shopName: json['shopName'] as String,
      treatmentName: json['treatmentName'] as String,
      treatmentPrice: json['treatmentPrice'] as int,
      treatmentDuration: json['treatmentDuration'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  UsageHistory toEntity() {
    return UsageHistory(
      id: id,
      memberId: memberId,
      shopId: shopId,
      reservationId: reservationId,
      shopName: shopName,
      treatmentName: treatmentName,
      treatmentPrice: treatmentPrice,
      treatmentDuration: treatmentDuration,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

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
