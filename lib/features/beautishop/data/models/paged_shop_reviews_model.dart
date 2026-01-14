import 'package:jellomark/features/beautishop/data/models/shop_review_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';

class PagedShopReviewsModel extends PagedShopReviews {
  const PagedShopReviewsModel({
    required List<ShopReviewModel> super.items,
    required super.hasNext,
    required super.totalElements,
  });

  factory PagedShopReviewsModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => ShopReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PagedShopReviewsModel(
      items: items,
      hasNext: json['hasNext'] as bool? ?? false,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}
