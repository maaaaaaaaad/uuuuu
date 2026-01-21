import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/favorite/data/models/favorite_shop_model.dart';
import 'package:jellomark/features/favorite/data/models/paged_favorites_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<FavoriteShopModel> addFavorite(String shopId);
  Future<void> removeFavorite(String shopId);
  Future<PagedFavoritesModel> getFavorites({
    required int page,
    required int size,
  });
  Future<bool> checkFavorite(String shopId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;

  FavoriteRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<FavoriteShopModel> addFavorite(String shopId) async {
    final response = await _apiClient.post('/api/favorites/$shopId');
    return FavoriteShopModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeFavorite(String shopId) async {
    await _apiClient.delete('/api/favorites/$shopId');
  }

  @override
  Future<PagedFavoritesModel> getFavorites({
    required int page,
    required int size,
  }) async {
    final response = await _apiClient.get(
      '/api/favorites',
      queryParameters: {'page': page, 'size': size},
    );
    return PagedFavoritesModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> checkFavorite(String shopId) async {
    final response = await _apiClient.get('/api/favorites/check/$shopId');
    final data = response.data as Map<String, dynamic>;
    return data['isFavorite'] as bool;
  }
}
