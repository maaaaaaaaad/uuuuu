import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_shop_reviews.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

enum ReviewSortType {
  createdAtDesc,
  ratingDesc,
  ratingAsc,
}

extension ReviewSortTypeExtension on ReviewSortType {
  String get apiValue {
    switch (this) {
      case ReviewSortType.createdAtDesc:
        return 'createdAt,desc';
      case ReviewSortType.ratingDesc:
        return 'rating,desc';
      case ReviewSortType.ratingAsc:
        return 'rating,asc';
    }
  }

  String get displayName {
    switch (this) {
      case ReviewSortType.createdAtDesc:
        return '최신순';
      case ReviewSortType.ratingDesc:
        return '평점 높은순';
      case ReviewSortType.ratingAsc:
        return '평점 낮은순';
    }
  }
}

class GetShopReviews {
  final BeautyShopRepository repository;

  GetShopReviews({required this.repository});

  Future<Either<Failure, PagedShopReviews>> call({
    required String shopId,
    int page = 0,
    int size = 20,
    ReviewSortType sort = ReviewSortType.createdAtDesc,
  }) {
    return repository.getShopReviews(
      shopId,
      page: page,
      size: size,
      sort: sort.apiValue,
    );
  }
}
