import 'package:dio/dio.dart';
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
  final Dio dio;

  DirectionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<DirectionsResponseModel> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final start = '$startLng,$startLat';
    final goal = '$endLng,$endLat';

    final response = await dio.get<Map<String, dynamic>>(
      '/map-direction/v1/driving',
      queryParameters: {
        'start': start,
        'goal': goal,
      },
    );

    return DirectionsResponseModel.fromJson(response.data!);
  }
}
