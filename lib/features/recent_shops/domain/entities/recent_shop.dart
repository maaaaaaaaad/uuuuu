import 'package:equatable/equatable.dart';

class RecentShop extends Equatable {
  final String shopId;
  final String shopName;
  final String? thumbnailUrl;
  final String? address;
  final double? rating;
  final DateTime viewedAt;
  final double? latitude;
  final double? longitude;
  final double? distance;

  const RecentShop({
    required this.shopId,
    required this.shopName,
    this.thumbnailUrl,
    this.address,
    this.rating,
    required this.viewedAt,
    this.latitude,
    this.longitude,
    this.distance,
  });

  RecentShop copyWith({
    String? shopId,
    String? shopName,
    String? thumbnailUrl,
    String? address,
    double? rating,
    DateTime? viewedAt,
    double? latitude,
    double? longitude,
    double? distance,
  }) {
    return RecentShop(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      viewedAt: viewedAt ?? this.viewedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
    );
  }

  String? get formattedDistance {
    if (distance == null) return null;
    return '${distance!.toStringAsFixed(1)}km';
  }

  @override
  List<Object?> get props => [
        shopId,
        shopName,
        thumbnailUrl,
        address,
        rating,
        viewedAt,
        latitude,
        longitude,
        distance,
      ];
}
