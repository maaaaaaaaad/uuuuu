import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/data/datasources/location_datasource.dart';
import 'package:jellomark/features/location/data/repositories/location_repository_impl.dart';
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
          () => mockDataSource.isPermissionGranted(),
        ).thenAnswer((_) async => true);
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

      test('should request permission when not granted', () async {
        final mockPosition = MockPosition();
        when(() => mockPosition.latitude).thenReturn(37.5665);
        when(() => mockPosition.longitude).thenReturn(126.9780);

        when(
          () => mockDataSource.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockDataSource.isPermissionGranted(),
        ).thenAnswer((_) async => false);
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
            () => mockDataSource.isPermissionGranted(),
          ).thenAnswer((_) async => false);
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
    });

    group('requestLocationPermission', () {
      test('should return true when permission granted', () async {
        when(
          () => mockDataSource.requestPermission(),
        ).thenAnswer((_) async => true);

        final result = await repository.requestLocationPermission();

        expect(result, const Right(true));
      });

      test('should return false when permission denied', () async {
        when(
          () => mockDataSource.requestPermission(),
        ).thenAnswer((_) async => false);

        final result = await repository.requestLocationPermission();

        expect(result, const Right(false));
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
  });
}
