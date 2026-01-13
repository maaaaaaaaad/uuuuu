import 'package:jellomark/features/review/data/models/review_model.dart';
import 'package:jellomark/features/review/domain/entities/paged_reviews.dart';

class PagedReviewsModel {
  final List<ReviewModel> items;
  final bool hasNext;
  final int totalElements;

  const PagedReviewsModel({
    required this.items,
    required this.hasNext,
    required this.totalElements,
  });

  factory PagedReviewsModel.fromJson(Map<String, dynamic> json) {
    return PagedReviewsModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool,
      totalElements: json['totalElements'] as int,
    );
  }

  PagedReviews toEntity() {
    return PagedReviews(
      items: items.map((e) => e.toEntity()).toList(),
      hasNext: hasNext,
      totalElements: totalElements,
    );
  }
}
