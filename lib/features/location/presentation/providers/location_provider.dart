import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';
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
