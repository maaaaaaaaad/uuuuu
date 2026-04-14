import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/features/external_shop/data/models/external_shop_model.dart';

class ExternalShopRemoteDataSource {
  final ApiClient apiClient;

  ExternalShopRemoteDataSource({required this.apiClient});

  Future<List<ExternalShopModel>> getNearbyExternalShops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    final response = await apiClient.get<List<dynamic>>(
      '/api/external-shops',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
      },
    );

    return (response.data ?? [])
        .map((json) => ExternalShopModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
