import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/data/datasources/location_datasource.dart';
import 'package:jellomark/features/location/data/repositories/location_repository_impl.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationDataSource extends Mock implements LocationDataSource {}

class MockPosition extends Mock implements Position {}

void main() {
  late LocationRepositoryImpl repository;
  late MockLocationDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocationDataSource();
    repository = LocationRepositoryImpl(mockDataSource);
  });

  group('LocationRepositoryImpl', () {
    group('getCurrentLocation', () {
      test('should return UserLocation when successful', () async {
        final mockPosition = MockPosition();
        when(() => mockPosition.latitude).thenReturn(37.5665);
        when(() => mockPosition.longitude).thenReturn(126.9780);

        when(
          () => mockDataSource.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.granted);
        when(
          () => mockDataSource.getCurrentPosition(),
        ).thenAnswer((_) async => mockPosition);

        final result = await repository.getCurrentLocation();

        expect(result, isA<Right>());
        result.fold((failure) => fail('Should not return failure'), (location) {
          expect(location.latitude, 37.5665);
          expect(location.longitude, 126.9780);
        });
      });

      test(
        'should return LocationServiceDisabledFailure when service disabled',
        () async {
          when(
            () => mockDataSource.isLocationServiceEnabled(),
          ).thenAnswer((_) async => false);

          final result = await repository.getCurrentLocation();

          expect(result, isA<Left>());
          result.fold(
            (failure) => expect(failure, isA<LocationServiceDisabledFailure>()),
            (_) => fail('Should return failure'),
          );
        },
      );

      test('should request permission when denied (not forever)', () async {
        final mockPosition = MockPosition();
        when(() => mockPosition.latitude).thenReturn(37.5665);
        when(() => mockPosition.longitude).thenReturn(126.9780);

        when(
          () => mockDataSource.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.denied);
        when(
          () => mockDataSource.requestPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockDataSource.getCurrentPosition(),
        ).thenAnswer((_) async => mockPosition);

        final result = await repository.getCurrentLocation();

        verify(() => mockDataSource.requestPermission()).called(1);
        expect(result, isA<Right>());
      });

      test(
        'should return LocationPermissionDeniedFailure when permission denied',
        () async {
          when(
            () => mockDataSource.isLocationServiceEnabled(),
          ).thenAnswer((_) async => true);
          when(
            () => mockDataSource.checkPermissionStatus(),
          ).thenAnswer((_) async => LocationPermissionStatus.denied);
          when(
            () => mockDataSource.requestPermission(),
          ).thenAnswer((_) async => false);

          final result = await repository.getCurrentLocation();

          expect(result, isA<Left>());
          result.fold(
            (failure) =>
                expect(failure, isA<LocationPermissionDeniedFailure>()),
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'should return LocationPermissionDeniedForeverFailure when deniedForever',
        () async {
          when(
            () => mockDataSource.isLocationServiceEnabled(),
          ).thenAnswer((_) async => true);
          when(
            () => mockDataSource.checkPermissionStatus(),
          ).thenAnswer((_) async => LocationPermissionStatus.deniedForever);

          final result = await repository.getCurrentLocation();

          expect(result, isA<Left>());
          result.fold(
            (failure) =>
                expect(failure, isA<LocationPermissionDeniedForeverFailure>()),
            (_) => fail('Should return failure'),
          );
        },
      );
    });

    group('requestLocationPermission', () {
      test('should return true when permission granted', () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.denied);
        when(
          () => mockDataSource.requestPermission(),
        ).thenAnswer((_) async => true);

        final result = await repository.requestLocationPermission();

        expect(result, const Right(true));
      });

      test('should return false when permission denied', () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.denied);
        when(
          () => mockDataSource.requestPermission(),
        ).thenAnswer((_) async => false);

        final result = await repository.requestLocationPermission();

        expect(result, const Right(false));
      });

      test('should return false when permission deniedForever', () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.deniedForever);

        final result = await repository.requestLocationPermission();

        expect(result, const Right(false));
        verifyNever(() => mockDataSource.requestPermission());
      });
    });

    group('isLocationPermissionGranted', () {
      test('should return true when permission is granted', () async {
        when(
          () => mockDataSource.isPermissionGranted(),
        ).thenAnswer((_) async => true);

        final result = await repository.isLocationPermissionGranted();

        expect(result, true);
      });

      test('should return false when permission is not granted', () async {
        when(
          () => mockDataSource.isPermissionGranted(),
        ).thenAnswer((_) async => false);

        final result = await repository.isLocationPermissionGranted();

        expect(result, false);
      });
    });

    group('checkPermissionStatus', () {
      test('should return granted when permission is granted', () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.granted);

        final result = await repository.checkPermissionStatus();

        expect(result, LocationPermissionResult.granted);
      });

      test('should return denied when permission is denied', () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.denied);

        final result = await repository.checkPermissionStatus();

        expect(result, LocationPermissionResult.denied);
      });

      test('should return deniedForever when permission is deniedForever',
          () async {
        when(
          () => mockDataSource.checkPermissionStatus(),
        ).thenAnswer((_) async => LocationPermissionStatus.deniedForever);

        final result = await repository.checkPermissionStatus();

        expect(result, LocationPermissionResult.deniedForever);
      });
    });

    group('openAppSettings', () {
      test('should call openAppSettings on dataSource', () async {
        when(
          () => mockDataSource.openAppSettings(),
        ).thenAnswer((_) async => true);

        final result = await repository.openAppSettings();

        expect(result, true);
        verify(() => mockDataSource.openAppSettings()).called(1);
      });
    });
  });
}
