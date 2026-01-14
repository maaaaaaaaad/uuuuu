import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

class ShopReviewModel extends ShopReview {
  const ShopReviewModel({
    required super.id,
    required super.authorName,
    super.rating,
    super.content,
    required super.createdAt,
    super.images = const [],
    super.authorProfileImage,
    super.serviceName,
  });

  factory ShopReviewModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>?;
    final images =
        imagesJson?.map((e) => e.toString()).toList() ?? const <String>[];

    return ShopReviewModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String? ?? '익명',
      rating: (json['rating'] as num?)?.toDouble(),
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: images,
      authorProfileImage: json['authorProfileImage'] as String?,
      serviceName: json['serviceName'] as String?,
    );
  }
}
