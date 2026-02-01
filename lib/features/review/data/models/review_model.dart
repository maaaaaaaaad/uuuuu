import 'package:equatable/equatable.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

class ReviewModel extends Equatable {
  final String id;
  final String shopId;
  final String? shopName;
  final String? shopImage;
  final String memberId;
  final int? rating;
  final String? content;
  final List<String> images;
  final String createdAt;
  final String updatedAt;

  const ReviewModel({
    required this.id,
    required this.shopId,
    this.shopName,
    this.shopImage,
    required this.memberId,
    this.rating,
    this.content,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String?,
      shopImage: json['shopImage'] as String?,
      memberId: json['memberId'] as String,
      rating: json['rating'] as int?,
      content: json['content'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'shopImage': shopImage,
      'memberId': memberId,
      'rating': rating,
      'content': content,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Review toEntity() {
    return Review(
      id: id,
      shopId: shopId,
      shopName: shopName,
      shopImage: shopImage,
      memberId: memberId,
      rating: rating,
      content: content,
      images: images,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        shopName,
        shopImage,
        memberId,
        rating,
        content,
        images,
        createdAt,
        updatedAt,
      ];
}
