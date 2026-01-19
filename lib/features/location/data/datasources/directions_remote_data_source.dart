import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jellomark/config/env_config.dart';
import 'package:jellomark/features/location/data/models/directions_response_model.dart';

abstract class DirectionsRemoteDataSource {
  Future<DirectionsResponseModel> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  static const String _baseUrl = 'https://naveropenapi.apigw.ntruss.com';
  static const String _endpoint = '/map-direction/v1/driving';

  late final Dio _dio;

  DirectionsRemoteDataSourceImpl() {
    _dio = Dio();
    debugPrint(
      '[DIRECT_API_CHECK] DirectionsRemoteDataSourceImpl created with NEW Dio()',
    );
  }

  @visibleForTesting
  DirectionsRemoteDataSourceImpl.withDio(Dio dio) : _dio = dio;

  @override
  Future<DirectionsResponseModel> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final start = '$startLng,$startLat';
    final goal = '$endLng,$endLat';
    final url = '$_baseUrl$_endpoint';

    final clientId = EnvConfig.naverMapClientId;
    final clientSecret = EnvConfig.naverClientSecret;

    debugPrint('[DIRECT_API_CHECK] ===== DIRECTIONS API CALL =====');
    debugPrint('[DIRECT_API_CHECK] URL: $url');
    debugPrint('[DIRECT_API_CHECK] Start: $start');
    debugPrint('[DIRECT_API_CHECK] Goal: $goal');
    debugPrint(
      '[DIRECT_API_CHECK] Client ID: ${clientId.isNotEmpty ? "${clientId.substring(0, 3)}..." : "EMPTY!"}',
    );
    debugPrint(
      '[DIRECT_API_CHECK] Client Secret: ${clientSecret.isNotEmpty ? "${clientSecret.substring(0, 3)}..." : "EMPTY!"}',
    );

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {'start': start, 'goal': goal, 'option': 'trafast'},
        options: Options(
          headers: {
            'X-NCP-APIGW-API-KEY-ID': clientId,
            'X-NCP-APIGW-API-KEY': clientSecret,
          },
        ),
      );

      debugPrint('[DIRECT_API_CHECK] Response Status: ${response.statusCode}');
      debugPrint('[DIRECT_API_CHECK] Response Code: ${response.data?['code']}');
      debugPrint(
        '[DIRECT_API_CHECK] Response Message: ${response.data?['message']}',
      );

      return DirectionsResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      debugPrint('[DIRECT_API_CHECK] ===== API ERROR =====');
      debugPrint('[DIRECT_API_CHECK] Status: ${e.response?.statusCode}');
      debugPrint('[DIRECT_API_CHECK] Error Type: ${e.type}');
      debugPrint('[DIRECT_API_CHECK] Message: ${e.message}');
      debugPrint('[DIRECT_API_CHECK] Response Body: ${e.response?.data}');
      debugPrint('[DIRECT_API_CHECK] Request URL: ${e.requestOptions.uri}');
      debugPrint(
        '[DIRECT_API_CHECK] Request Headers: ${e.requestOptions.headers}',
      );
      rethrow;
    }
  }
}
