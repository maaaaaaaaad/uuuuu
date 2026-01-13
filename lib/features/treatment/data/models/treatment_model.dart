import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';

class TreatmentModel extends ServiceMenu {
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TreatmentModel({
    required super.id,
    required super.name,
    required super.price,
    super.durationMinutes,
    super.description,
    super.category,
    super.discountPrice,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      durationMinutes: json['duration'] as int?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'price': price,
      'duration': durationMinutes,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
