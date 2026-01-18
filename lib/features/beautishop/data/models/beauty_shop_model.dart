import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

class BeautyShopModel extends BeautyShop {
  final String phoneNumber;
  final String? description;
  final Map<String, String> operatingTimeMap;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BeautyShopModel({
    required super.id,
    required super.name,
    required super.address,
    super.latitude,
    super.longitude,
    super.imageUrl,
    super.rating,
    super.reviewCount,
    super.distance,
    super.tags,
    super.discountRate,
    super.isNew,
    super.operatingHours,
    required this.phoneNumber,
    this.description,
    required this.operatingTimeMap,
    required this.createdAt,
    required this.updatedAt,
  });

  static const _englishToKoreanDays = {
    'monday': '월',
    'tuesday': '화',
    'wednesday': '수',
    'thursday': '목',
    'friday': '금',
    'saturday': '토',
    'sunday': '일',
  };

  factory BeautyShopModel.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as List<dynamic>? ?? [];
    final tags = categories.map((c) => c['name'] as String).toList();

    final rawOperatingTime = Map<String, String>.from(
      json['operatingTime'] as Map<String, dynamic>? ?? {},
    );
    final operatingTime = _convertToKoreanDays(rawOperatingTime);
    final operatingHours = _formatOperatingHours(operatingTime);

    final createdAt = DateTime.parse(json['createdAt'] as String);
    final isNew = DateTime.now().difference(createdAt).inDays <= 30;

    return BeautyShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image'] as String?,
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      tags: tags,
      isNew: isNew,
      operatingHours: operatingHours,
      phoneNumber: json['phoneNumber'] as String,
      description: json['description'] as String?,
      operatingTimeMap: operatingTime,
      createdAt: createdAt,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image': imageUrl,
      'averageRating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'categories': tags.map((t) => {'name': t}).toList(),
      'operatingTime': operatingTimeMap,
      'phoneNumber': phoneNumber,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String _formatOperatingHours(Map<String, String> operatingTime) {
    if (operatingTime.isEmpty) return '';
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final parts = <String>[];
    for (final day in days) {
      if (operatingTime.containsKey(day)) {
        parts.add('$day: ${operatingTime[day]}');
      }
    }
    return parts.join(', ');
  }

  static Map<String, String> _convertToKoreanDays(Map<String, String> raw) {
    final result = <String, String>{};
    for (final entry in raw.entries) {
      final koreanDay = _englishToKoreanDays[entry.key.toLowerCase()];
      if (koreanDay != null) {
        result[koreanDay] = entry.value;
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  @override
  BeautyShopModel copyWith({
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
    String? phoneNumber,
    String? description,
    Map<String, String>? operatingTimeMap,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeautyShopModel(
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      operatingTimeMap: operatingTimeMap ?? this.operatingTimeMap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
