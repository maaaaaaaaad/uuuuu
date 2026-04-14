import 'package:jellomark/features/external_shop/domain/entities/external_shop.dart';

class ExternalShopModel extends ExternalShop {
  const ExternalShopModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.category,
    super.phoneNumber,
  });

  factory ExternalShopModel.fromJson(Map<String, dynamic> json) {
    return ExternalShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
