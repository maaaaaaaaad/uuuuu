import 'package:equatable/equatable.dart';

class RecentShop extends Equatable {
  final String shopId;
  final String shopName;
  final String? thumbnailUrl;
  final String? address;
  final double? rating;
  final DateTime viewedAt;

  const RecentShop({
    required this.shopId,
    required this.shopName,
    this.thumbnailUrl,
    this.address,
    this.rating,
    required this.viewedAt,
  });

  @override
  List<Object?> get props => [
        shopId,
        shopName,
        thumbnailUrl,
        address,
        rating,
        viewedAt,
      ];
}
