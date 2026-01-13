import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';

class PagedBeautyShopsModel {
  final List<BeautyShopModel> items;
  final bool hasNext;
  final int totalElements;

  const PagedBeautyShopsModel({
    required this.items,
    required this.hasNext,
    required this.totalElements,
  });

  factory PagedBeautyShopsModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => BeautyShopModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PagedBeautyShopsModel(
      items: items,
      hasNext: json['hasNext'] as bool? ?? false,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}
