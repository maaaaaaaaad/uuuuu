import 'package:equatable/equatable.dart';

class BeautyShop extends Equatable {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final double? distance;
  final List<String> tags;
  final int? discountRate;
  final bool isNew;
  final String? operatingHours;

  const BeautyShop({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distance,
    this.tags = const [],
    this.discountRate,
    this.isNew = false,
    this.operatingHours,
  });

  String? get formattedDistance {
    if (distance == null) return null;
    return '${distance!.toStringAsFixed(1)}km';
  }

  BeautyShop copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    double? distance,
    List<String>? tags,
    int? discountRate,
    bool? isNew,
    String? operatingHours,
  }) {
    return BeautyShop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      tags: tags ?? this.tags,
      discountRate: discountRate ?? this.discountRate,
      isNew: isNew ?? this.isNew,
      operatingHours: operatingHours ?? this.operatingHours,
    );
  }

  String get formattedRating => rating.toStringAsFixed(1);

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        imageUrl,
        rating,
        reviewCount,
        distance,
        tags,
        discountRate,
        isNew,
        operatingHours,
      ];
}
