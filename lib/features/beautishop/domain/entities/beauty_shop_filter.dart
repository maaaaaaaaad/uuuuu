import 'package:equatable/equatable.dart';

class BeautyShopFilter extends Equatable {
  final int page;
  final int size;
  final String? keyword;
  final String? sortBy;
  final String? sortOrder;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final double? minRating;

  const BeautyShopFilter({
    this.page = 0,
    this.size = 20,
    this.keyword,
    this.sortBy,
    this.sortOrder,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.minRating,
  });

  BeautyShopFilter copyWith({
    int? page,
    int? size,
    String? keyword,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? minRating,
  }) {
    return BeautyShopFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      keyword: keyword ?? this.keyword,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      categoryId: categoryId ?? this.categoryId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      minRating: minRating ?? this.minRating,
    );
  }

  @override
  List<Object?> get props => [
    page,
    size,
    keyword,
    sortBy,
    sortOrder,
    categoryId,
    latitude,
    longitude,
    minRating,
  ];
}
