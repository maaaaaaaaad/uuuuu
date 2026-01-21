import 'package:equatable/equatable.dart';
import 'package:jellomark/features/favorite/domain/entities/favorite_shop.dart';

class PagedFavorites extends Equatable {
  final List<FavoriteShop> items;
  final bool hasNext;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  const PagedFavorites({
    required this.items,
    required this.hasNext,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  @override
  List<Object?> get props => [items, hasNext, totalElements, totalPages, page, size];
}
