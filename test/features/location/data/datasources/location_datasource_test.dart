import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/data/datasources/location_datasource.dart';

void main() {
  group('LocationDataSource', () {
    test('LocationDataSourceImpl should implement LocationDataSource', () {
      final dataSource = LocationDataSourceImpl();
      expect(dataSource, isA<LocationDataSource>());
    });
  });
}
