import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop_filter.dart';
import 'package:jellomark/features/beautishop/domain/entities/paged_beauty_shops.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

class GetFilteredShopsUseCase {
  final BeautyShopRepository _repository;

  GetFilteredShopsUseCase({required BeautyShopRepository repository})
    : _repository = repository;

  Future<Either<Failure, PagedBeautyShops>> call(BeautyShopFilter filter) {
    return _repository.getBeautyShops(
      page: filter.page,
      size: filter.size,
      keyword: filter.keyword,
      sortBy: filter.sortBy,
      sortOrder: filter.sortOrder,
      categoryId: filter.categoryId,
      latitude: filter.latitude,
      longitude: filter.longitude,
      minRating: filter.minRating,
    );
  }
}
