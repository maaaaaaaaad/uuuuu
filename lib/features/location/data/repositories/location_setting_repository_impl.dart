import 'package:jellomark/features/location/data/datasources/location_setting_local_datasource.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';

class LocationSettingRepositoryImpl implements LocationSettingRepository {
  final LocationSettingLocalDataSource dataSource;

  LocationSettingRepositoryImpl({required this.dataSource});

  @override
  Future<bool> isLocationEnabled() async {
    return await dataSource.isLocationEnabled();
  }

  @override
  Future<void> setLocationEnabled(bool enabled) async {
    await dataSource.setLocationEnabled(enabled);
  }
}
