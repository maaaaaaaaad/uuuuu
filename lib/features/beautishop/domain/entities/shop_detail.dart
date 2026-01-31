import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

class ShopDetail extends BeautyShop {
  final String description;
  final String phoneNumber;
  final Map<String, String>? operatingHoursMap;
  final String? notice;

  const ShopDetail({
    required super.id,
    required super.name,
    required super.address,
    required this.description,
    required this.phoneNumber,
    super.images,
    this.operatingHoursMap,
    this.notice,
    super.latitude,
    super.longitude,
    super.rating,
    super.reviewCount,
    super.distance,
    super.tags,
    super.discountRate,
    super.isNew,
    super.operatingHours,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        description,
        phoneNumber,
        operatingHoursMap,
        notice,
      ];
}
