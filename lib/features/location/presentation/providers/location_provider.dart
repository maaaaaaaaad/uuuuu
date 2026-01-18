import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
import 'package:jellomark/features/location/domain/repositories/directions_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/usecases/get_current_location_usecase.dart';

final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocationUseCase>(
  (ref) => sl<GetCurrentLocationUseCase>(),
);

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => sl<LocationRepository>(),
);

final currentLocationProvider =
    FutureProvider.autoDispose<UserLocation?>((ref) async {
  final useCase = ref.watch(getCurrentLocationUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => null,
    (location) => location,
  );
});

final locationPermissionStatusProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.isLocationPermissionGranted();
});

final directionsRepositoryProvider = Provider<DirectionsRepository>(
  (ref) => sl<DirectionsRepository>(),
);

class RouteParams extends Equatable {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  const RouteParams({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
  });

  @override
  List<Object?> get props => [startLat, startLng, endLat, endLng];
}

final routeProvider =
    FutureProvider.autoDispose.family<Route?, RouteParams>((ref, params) async {
  debugPrint('[routeProvider] Fetching route: start=(${params.startLat}, ${params.startLng}), end=(${params.endLat}, ${params.endLng})');
  final repository = ref.watch(directionsRepositoryProvider);
  final result = await repository.getRoute(
    startLat: params.startLat,
    startLng: params.startLng,
    endLat: params.endLat,
    endLng: params.endLng,
  );
  return result.fold(
    (failure) {
      debugPrint('[routeProvider] Route fetch failed: $failure');
      return null;
    },
    (route) {
      debugPrint('[routeProvider] Route fetched: ${route.coordinates.length} coords, ${route.distanceInMeters}m');
      return route;
    },
  );
});
