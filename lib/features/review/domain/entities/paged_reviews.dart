import 'package:equatable/equatable.dart';
import 'package:jellomark/features/review/domain/entities/review.dart';

class PagedReviews extends Equatable {
  final List<Review> items;
  final bool hasNext;
  final int totalElements;

  const PagedReviews({
    required this.items,
    required this.hasNext,
    required this.totalElements,
  });

  @override
  List<Object?> get props => [items, hasNext, totalElements];
}
