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

    debugPrint('[DirectionsAPI] Request: $url?start=$start&goal=$goal');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {'start': start, 'goal': goal, 'option': 'trafast'},
        options: Options(
          headers: {
            'X-NCP-APIGW-API-KEY-ID': EnvConfig.naverMapClientId,
            'X-NCP-APIGW-API-KEY': EnvConfig.naverClientSecret,
          },
        ),
      );

      debugPrint('[DirectionsAPI] Response: ${response.statusCode}');
      return DirectionsResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      debugPrint(
        '[DirectionsAPI] Error: ${e.response?.statusCode} - ${e.message}',
      );
      debugPrint('[DirectionsAPI] URL: ${e.requestOptions.uri}');
      rethrow;
    }
  }
}
