import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_setting_provider.dart';

class LocationPermissionAlertNotifier extends Notifier<bool> {
  bool _hasShownThisSession = false;

  bool get hasShownThisSession => _hasShownThisSession;

  @override
  bool build() {
    return _hasShownThisSession;
  }

  Future<bool> shouldShowAlert() async {
    if (_hasShownThisSession) {
      return false;
    }

    final locationRepository = ref.read(locationRepositoryForSettingProvider);
    final permissionStatus = await locationRepository.checkPermissionStatus();

    return permissionStatus == LocationPermissionResult.denied ||
        permissionStatus == LocationPermissionResult.deniedForever;
  }

  void markAsShown() {
    _hasShownThisSession = true;
    state = true;
  }
}

final locationPermissionAlertProvider =
    NotifierProvider<LocationPermissionAlertNotifier, bool>(
  LocationPermissionAlertNotifier.new,
);
