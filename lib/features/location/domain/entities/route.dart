import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class Route extends Equatable {
  final List<LatLng> coordinates;
  final int distanceInMeters;
  final int durationInMillis;

  const Route({
    required this.coordinates,
    required this.distanceInMeters,
    required this.durationInMillis,
  });

  String get formattedDistance {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters}m';
    }
    final km = distanceInMeters / 1000;
    return '${km.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}km';
  }

  String get formattedDuration {
    final minutes = durationInMillis ~/ 60000;
    if (minutes < 60) {
      return '$minutes분';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours시간 $remainingMinutes분';
  }

  @override
  List<Object?> get props => [coordinates, distanceInMeters, durationInMillis];
}
