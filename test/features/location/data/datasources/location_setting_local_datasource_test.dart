import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/data/datasources/location_setting_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocationSettingLocalDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = LocationSettingLocalDataSourceImpl();
  });

  group('LocationSettingLocalDataSource', () {
    test('should return true when location setting is not set (default)', () async {
      final result = await dataSource.isLocationEnabled();

      expect(result, isTrue);
    });

    test('should return false when location setting is disabled', () async {
      await dataSource.setLocationEnabled(false);

      final result = await dataSource.isLocationEnabled();

      expect(result, isFalse);
    });

    test('should return true when location setting is enabled', () async {
      await dataSource.setLocationEnabled(false);
      await dataSource.setLocationEnabled(true);

      final result = await dataSource.isLocationEnabled();

      expect(result, isTrue);
    });

    test('should persist setting across instances', () async {
      await dataSource.setLocationEnabled(false);

      final newDataSource = LocationSettingLocalDataSourceImpl();
      final result = await newDataSource.isLocationEnabled();

      expect(result, isFalse);
    });
  });
}
