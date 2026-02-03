import 'package:equatable/equatable.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

class FavoriteShop extends Equatable {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final BeautyShop? shop;

  const FavoriteShop({
    required this.id,
    required this.shopId,
    required this.createdAt,
    this.shop,
  });

  FavoriteShop copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    BeautyShop? shop,
  }) {
    return FavoriteShop(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      shop: shop ?? this.shop,
    );
  }

  @override
  List<Object?> get props => [id, shopId, createdAt, shop];
}
