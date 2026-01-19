import 'package:dio/dio.dart';
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
  final Dio _dio;

  DirectionsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  factory DirectionsRemoteDataSourceImpl.create() {
    final dio = Dio(BaseOptions(
      baseUrl: EnvConfig.naverApiBaseUrl,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': EnvConfig.naverClientId,
        'X-NCP-APIGW-API-KEY': EnvConfig.naverClientSecret,
      },
    ));
    return DirectionsRemoteDataSourceImpl(dio: dio);
  }

  @override
  Future<DirectionsResponseModel> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final start = '$startLng,$startLat';
    final goal = '$endLng,$endLat';

    final response = await _dio.get<Map<String, dynamic>>(
      '/map-direction/v1/driving',
      queryParameters: {
        'start': start,
        'goal': goal,
      },
    );

    return DirectionsResponseModel.fromJson(response.data!);
  }
}
