import 'package:jellomark/features/location/domain/entities/route.dart';

class DirectionsResponseModel {
  final int code;
  final String message;
  final List<LatLng>? coordinates;
  final int? distanceInMeters;
  final int? durationInMillis;

  const DirectionsResponseModel({
    required this.code,
    required this.message,
    this.coordinates,
    this.distanceInMeters,
    this.durationInMillis,
  });

  bool get isSuccess => code == 0;

  factory DirectionsResponseModel.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as int;
    final message = json['message'] as String;

    List<LatLng>? coordinates;
    int? distanceInMeters;
    int? durationInMillis;

    if (code == 0 && json['route'] != null) {
      final route = json['route'] as Map<String, dynamic>;
      final traoptimal = route['traoptimal'] as List<dynamic>?;

      if (traoptimal != null && traoptimal.isNotEmpty) {
        final firstRoute = traoptimal.first as Map<String, dynamic>;

        final path = firstRoute['path'] as List<dynamic>;
        coordinates = path.map((coord) {
          final coordList = coord as List<dynamic>;
          final lng = (coordList[0] as num).toDouble();
          final lat = (coordList[1] as num).toDouble();
          return LatLng(latitude: lat, longitude: lng);
        }).toList();

        final summary = firstRoute['summary'] as Map<String, dynamic>;
        distanceInMeters = summary['distance'] as int;
        durationInMillis = summary['duration'] as int;
      }
    }

    return DirectionsResponseModel(
      code: code,
      message: message,
      coordinates: coordinates,
      distanceInMeters: distanceInMeters,
      durationInMillis: durationInMillis,
    );
  }

  Route? toRoute() {
    if (coordinates == null ||
        distanceInMeters == null ||
        durationInMillis == null) {
      return null;
    }

    return Route(
      coordinates: coordinates!,
      distanceInMeters: distanceInMeters!,
      durationInMillis: durationInMillis!,
    );
  }
}
