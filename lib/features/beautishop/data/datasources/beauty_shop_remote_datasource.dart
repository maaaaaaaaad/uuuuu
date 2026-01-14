import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/beautishop/data/models/beauty_shop_model.dart';
import 'package:jellomark/features/beautishop/data/models/paged_beauty_shops_model.dart';
import 'package:jellomark/features/beautishop/data/models/paged_shop_reviews_model.dart';

abstract class BeautyShopRemoteDataSource {
  Future<PagedBeautyShopsModel> getBeautyShops({
    required int page,
    required int size,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? minRating,
  });

  Future<BeautyShopModel> getBeautyShopById(String shopId);

  Future<PagedShopReviewsModel> getShopReviews(
    String shopId, {
    required int page,
    required int size,
    required String sort,
  });
}

class BeautyShopRemoteDataSourceImpl implements BeautyShopRemoteDataSource {
  final ApiClient _apiClient;

  BeautyShopRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<PagedBeautyShopsModel> getBeautyShops({
    required int page,
    required int size,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? minRating,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;
    if (categoryId != null) queryParameters['categoryId'] = categoryId;
    if (latitude != null) queryParameters['latitude'] = latitude;
    if (longitude != null) queryParameters['longitude'] = longitude;
    if (minRating != null) queryParameters['minRating'] = minRating;

    final response = await _apiClient.get(
      '/api/beautishops',
      queryParameters: queryParameters,
    );

    return PagedBeautyShopsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<BeautyShopModel> getBeautyShopById(String shopId) async {
    final response = await _apiClient.get('/api/beautishops/$shopId');
    return BeautyShopModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PagedShopReviewsModel> getShopReviews(
    String shopId, {
    required int page,
    required int size,
    required String sort,
  }) async {
    final response = await _apiClient.get(
      '/api/beautishops/$shopId/reviews',
      queryParameters: {
        'page': page,
        'size': size,
        'sort': sort,
      },
    );

    return PagedShopReviewsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
