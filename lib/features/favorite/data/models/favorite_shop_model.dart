import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';

class ShopSummary {
  final String id;
  final String name;
  final String address;
  final List<String> images;
  final double averageRating;
  final int reviewCount;

  const ShopSummary({
    required this.id,
    required this.name,
    required this.address,
    this.images = const [],
    required this.averageRating,
    required this.reviewCount,
  });

  factory ShopSummary.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'] as List<dynamic>? ?? [];
    final images = imagesRaw.map((e) => e as String).toList();

    return ShopSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      images: images,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  BeautyShop toBeautyShop() {
    return BeautyShop(
      id: id,
      name: name,
      address: address,
      images: images,
      rating: averageRating,
      reviewCount: reviewCount,
    );
  }
}

class FavoriteShopModel extends FavoriteShop {
  const FavoriteShopModel({
    required super.id,
    required super.shopId,
    required super.createdAt,
    super.shop,
  });

  factory FavoriteShopModel.fromJson(Map<String, dynamic> json) {
    final shopJson = json['shop'] as Map<String, dynamic>?;
    final shop = shopJson != null ? ShopSummary.fromJson(shopJson).toBeautyShop() : null;

    return FavoriteShopModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shop: shop,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
