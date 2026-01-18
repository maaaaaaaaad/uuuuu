abstract class LocationSettingRepository {
  Future<bool> isLocationEnabled();
  Future<void> setLocationEnabled(bool enabled);
}
