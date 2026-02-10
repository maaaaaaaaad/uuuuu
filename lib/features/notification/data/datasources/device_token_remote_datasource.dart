import 'package:jellomark/core/network/api_client.dart';

abstract class DeviceTokenRemoteDataSource {
  Future<void> registerToken(String token, String platform);
  Future<void> unregisterToken(String token);
}

class DeviceTokenRemoteDataSourceImpl implements DeviceTokenRemoteDataSource {
  final ApiClient _apiClient;

  DeviceTokenRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<void> registerToken(String token, String platform) async {
    await _apiClient.post(
      '/api/device-tokens',
      data: {'token': token, 'platform': platform},
    );
  }

  @override
  Future<void> unregisterToken(String token) async {
    await _apiClient.delete('/api/device-tokens/$token');
  }
}
