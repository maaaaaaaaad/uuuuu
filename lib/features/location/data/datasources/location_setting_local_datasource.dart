import 'package:shared_preferences/shared_preferences.dart';

abstract class LocationSettingLocalDataSource {
  Future<bool> isLocationEnabled();
  Future<void> setLocationEnabled(bool enabled);
}

class LocationSettingLocalDataSourceImpl implements LocationSettingLocalDataSource {
  static const String _locationEnabledKey = 'location_enabled';

  @override
  Future<bool> isLocationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationEnabledKey) ?? true;
  }

  @override
  Future<void> setLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationEnabledKey, enabled);
  }
}
