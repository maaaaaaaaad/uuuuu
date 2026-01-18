import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus { granted, denied, deniedForever }

abstract class LocationDataSource {
  Future<Position> getCurrentPosition();

  Future<bool> requestPermission();

  Future<bool> isPermissionGranted();

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermissionStatus> checkPermissionStatus();

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    debugPrint(
      '[LocationDataSource] Calling Geolocator.requestPermission()...',
    );
    final permission = await Geolocator.requestPermission();
    debugPrint('[LocationDataSource] requestPermission result: $permission');
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    final permission = await Geolocator.checkPermission();
    debugPrint('[LocationDataSource] checkPermissionStatus raw: $permission');
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
