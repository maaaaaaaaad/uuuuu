import 'package:equatable/equatable.dart';
import 'package:jellomark/features/beautishop/domain/entities/shop_review.dart';

class PagedShopReviews extends Equatable {
  final List<ShopReview> items;
  final bool hasNext;
  final int totalElements;

  const PagedShopReviews({
    required this.items,
    required this.hasNext,
    required this.totalElements,
  });

  @override
  List<Object?> get props => [items, hasNext, totalElements];
}
