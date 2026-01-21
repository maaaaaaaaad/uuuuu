import 'package:jellomark/features/favorite/data/models/favorite_shop_model.dart';
import 'package:jellomark/features/favorite/domain/entities/paged_favorites.dart';

class PagedFavoritesModel extends PagedFavorites {
  const PagedFavoritesModel({
    required super.items,
    required super.hasNext,
    required super.totalElements,
    required super.totalPages,
    required super.page,
    required super.size,
  });

  factory PagedFavoritesModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>;
    final items = itemsList
        .map((item) => FavoriteShopModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PagedFavoritesModel(
      items: items,
      hasNext: json['hasNext'] as bool,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}
