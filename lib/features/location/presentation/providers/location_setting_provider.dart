import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/data/datasources/location_setting_local_datasource.dart';
import 'package:jellomark/features/location/data/repositories/location_setting_repository_impl.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';

enum LocationSettingToggleResult {
  success,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationSettingState {
  final bool isEnabled;
  final LocationPermissionResult permissionStatus;

  const LocationSettingState({
    required this.isEnabled,
    required this.permissionStatus,
  });

  LocationSettingState copyWith({
    bool? isEnabled,
    LocationPermissionResult? permissionStatus,
  }) {
    return LocationSettingState(
      isEnabled: isEnabled ?? this.isEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
    );
  }
}

final locationSettingLocalDataSourceProvider =
    Provider<LocationSettingLocalDataSource>(
  (ref) => LocationSettingLocalDataSourceImpl(),
);

final locationSettingRepositoryProvider = Provider<LocationSettingRepository>(
  (ref) {
    final dataSource = ref.watch(locationSettingLocalDataSourceProvider);
    return LocationSettingRepositoryImpl(dataSource: dataSource);
  },
);

final locationRepositoryForSettingProvider = Provider<LocationRepository>(
  (ref) => sl<LocationRepository>(),
);

final locationSettingProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationSettingRepositoryProvider);
  return await repository.isLocationEnabled();
});

class LocationSettingNotifier extends AsyncNotifier<LocationSettingState> {
  @override
  Future<LocationSettingState> build() async {
    final settingRepository = ref.watch(locationSettingRepositoryProvider);
    final locationRepository = ref.watch(locationRepositoryForSettingProvider);

    final isEnabled = await settingRepository.isLocationEnabled();
    final permissionStatus = await locationRepository.checkPermissionStatus();

    return LocationSettingState(
      isEnabled: isEnabled,
      permissionStatus: permissionStatus,
    );
  }

  Future<LocationSettingToggleResult> toggle() async {
    final currentState = state.requireValue;
    final settingRepository = ref.read(locationSettingRepositoryProvider);
    final locationRepository = ref.read(locationRepositoryForSettingProvider);

    if (currentState.isEnabled) {
      await settingRepository.setLocationEnabled(false);
      state = AsyncData(currentState.copyWith(isEnabled: false));
      return LocationSettingToggleResult.success;
    } else {
      final permissionStatus = await locationRepository.checkPermissionStatus();

      if (permissionStatus == LocationPermissionResult.deniedForever) {
        return LocationSettingToggleResult.deniedForever;
      }

      if (permissionStatus == LocationPermissionResult.denied) {
        final Either<Failure, bool> result =
            await locationRepository.requestLocationPermission();
        final granted = result.fold((_) => false, (value) => value);
        if (!granted) {
          return LocationSettingToggleResult.denied;
        }
      }

      await settingRepository.setLocationEnabled(true);
      final newPermissionStatus =
          await locationRepository.checkPermissionStatus();
      state = AsyncData(currentState.copyWith(
        isEnabled: true,
        permissionStatus: newPermissionStatus,
      ));
      return LocationSettingToggleResult.success;
    }
  }

  Future<bool> openAppSettings() async {
    final locationRepository = ref.read(locationRepositoryForSettingProvider);
    return await locationRepository.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    final locationRepository = ref.read(locationRepositoryForSettingProvider);
    return await locationRepository.openLocationSettings();
  }

  Future<LocationSettingToggleResult> requestPermissionAndEnable() async {
    final settingRepository = ref.read(locationSettingRepositoryProvider);
    final locationRepository = ref.read(locationRepositoryForSettingProvider);

    final isServiceEnabled = await locationRepository.isLocationServiceEnabled();
    debugPrint('[LocationSetting] isLocationServiceEnabled: $isServiceEnabled');

    if (!isServiceEnabled) {
      debugPrint('[LocationSetting] Location services are disabled!');
      return LocationSettingToggleResult.serviceDisabled;
    }

    final permissionStatus = await locationRepository.checkPermissionStatus();
    debugPrint('[LocationSetting] checkPermissionStatus: $permissionStatus');

    if (permissionStatus == LocationPermissionResult.granted) {
      debugPrint('[LocationSetting] Permission already granted, enabling...');
      await settingRepository.setLocationEnabled(true);
      final newState = LocationSettingState(
        isEnabled: true,
        permissionStatus: permissionStatus,
      );
      state = AsyncData(newState);
      return LocationSettingToggleResult.success;
    }

    // deniedForever라도 requestPermission을 호출해야 iOS 시스템 다이얼로그가 표시됨
    // iOS에서 앱 삭제 후에도 권한 상태가 캐싱될 수 있어 실제 요청이 필요
    debugPrint('[LocationSetting] Requesting permission (status: $permissionStatus)...');
    final result = await locationRepository.requestLocationPermission();
    debugPrint('[LocationSetting] requestLocationPermission result: $result');
    final granted = result.fold((_) => false, (value) => value);

    if (!granted) {
      final newPermissionStatus =
          await locationRepository.checkPermissionStatus();
      if (newPermissionStatus == LocationPermissionResult.deniedForever) {
        return LocationSettingToggleResult.deniedForever;
      }
      return LocationSettingToggleResult.denied;
    }

    await settingRepository.setLocationEnabled(true);
    final newPermissionStatus = await locationRepository.checkPermissionStatus();
    final newState = LocationSettingState(
      isEnabled: true,
      permissionStatus: newPermissionStatus,
    );
    state = AsyncData(newState);
    return LocationSettingToggleResult.success;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final locationSettingNotifierProvider =
    AsyncNotifierProvider<LocationSettingNotifier, LocationSettingState>(
  LocationSettingNotifier.new,
);
