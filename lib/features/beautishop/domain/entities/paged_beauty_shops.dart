import 'package:equatable/equatable.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';

class PagedBeautyShops extends Equatable {
  final List<BeautyShop> items;
  final bool hasNext;
  final int totalElements;

  const PagedBeautyShops({
    required this.items,
    required this.hasNext,
    required this.totalElements,
  });

  @override
  List<Object?> get props => [items, hasNext, totalElements];
}
