import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/data/datasources/location_setting_local_datasource.dart';
import 'package:jellomark/features/location/data/repositories/location_setting_repository_impl.dart';
import 'package:jellomark/features/location/domain/repositories/location_setting_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationSettingLocalDataSource extends Mock
    implements LocationSettingLocalDataSource {}

void main() {
  late LocationSettingRepository repository;
  late MockLocationSettingLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocationSettingLocalDataSource();
    repository = LocationSettingRepositoryImpl(dataSource: mockDataSource);
  });

  group('LocationSettingRepositoryImpl', () {
    group('isLocationEnabled', () {
      test('should return true when data source returns true', () async {
        when(() => mockDataSource.isLocationEnabled())
            .thenAnswer((_) async => true);

        final result = await repository.isLocationEnabled();

        expect(result, isTrue);
        verify(() => mockDataSource.isLocationEnabled()).called(1);
      });

      test('should return false when data source returns false', () async {
        when(() => mockDataSource.isLocationEnabled())
            .thenAnswer((_) async => false);

        final result = await repository.isLocationEnabled();

        expect(result, isFalse);
        verify(() => mockDataSource.isLocationEnabled()).called(1);
      });
    });

    group('setLocationEnabled', () {
      test('should call data source with true', () async {
        when(() => mockDataSource.setLocationEnabled(true))
            .thenAnswer((_) async {});

        await repository.setLocationEnabled(true);

        verify(() => mockDataSource.setLocationEnabled(true)).called(1);
      });

      test('should call data source with false', () async {
        when(() => mockDataSource.setLocationEnabled(false))
            .thenAnswer((_) async {});

        await repository.setLocationEnabled(false);

        verify(() => mockDataSource.setLocationEnabled(false)).called(1);
      });
    });
  });
}
