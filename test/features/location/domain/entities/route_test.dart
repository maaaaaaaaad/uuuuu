import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';

void main() {
  group('LatLng', () {
    test('creates instance with latitude and longitude', () {
      const latLng = LatLng(latitude: 37.5665, longitude: 126.9780);

      expect(latLng.latitude, equals(37.5665));
      expect(latLng.longitude, equals(126.9780));
    });

    test('equality works correctly', () {
      const latLng1 = LatLng(latitude: 37.5665, longitude: 126.9780);
      const latLng2 = LatLng(latitude: 37.5665, longitude: 126.9780);

      expect(latLng1, equals(latLng2));
    });

    test('different coordinates creates unequal instances', () {
      const latLng1 = LatLng(latitude: 37.5665, longitude: 126.9780);
      const latLng2 = LatLng(latitude: 37.5666, longitude: 126.9780);

      expect(latLng1, isNot(equals(latLng2)));
    });
  });

  group('Route', () {
    test('creates instance with required fields', () {
      const coordinates = [
        LatLng(latitude: 37.5665, longitude: 126.9780),
        LatLng(latitude: 37.5700, longitude: 126.9800),
      ];
      final route = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );

      expect(route.coordinates, equals(coordinates));
      expect(route.distanceInMeters, equals(1234));
      expect(route.durationInMillis, equals(600000));
    });

    test('equality works correctly', () {
      const coordinates = [
        LatLng(latitude: 37.5665, longitude: 126.9780),
        LatLng(latitude: 37.5700, longitude: 126.9800),
      ];
      final route1 = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );
      final route2 = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );

      expect(route1, equals(route2));
    });

    test('different coordinates creates unequal instances', () {
      const coordinates1 = [
        LatLng(latitude: 37.5665, longitude: 126.9780),
      ];
      const coordinates2 = [
        LatLng(latitude: 37.5666, longitude: 126.9780),
      ];
      final route1 = Route(
        coordinates: coordinates1,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );
      final route2 = Route(
        coordinates: coordinates2,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );

      expect(route1, isNot(equals(route2)));
    });

    test('different distance creates unequal instances', () {
      const coordinates = [
        LatLng(latitude: 37.5665, longitude: 126.9780),
      ];
      final route1 = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );
      final route2 = Route(
        coordinates: coordinates,
        distanceInMeters: 5678,
        durationInMillis: 600000,
      );

      expect(route1, isNot(equals(route2)));
    });

    test('different duration creates unequal instances', () {
      const coordinates = [
        LatLng(latitude: 37.5665, longitude: 126.9780),
      ];
      final route1 = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 600000,
      );
      final route2 = Route(
        coordinates: coordinates,
        distanceInMeters: 1234,
        durationInMillis: 900000,
      );

      expect(route1, isNot(equals(route2)));
    });

    test('formattedDistance returns meters for distance less than 1km', () {
      final route = Route(
        coordinates: const [],
        distanceInMeters: 500,
        durationInMillis: 60000,
      );

      expect(route.formattedDistance, equals('500m'));
    });

    test('formattedDistance returns km for distance 1km or more', () {
      final route = Route(
        coordinates: const [],
        distanceInMeters: 2500,
        durationInMillis: 300000,
      );

      expect(route.formattedDistance, equals('2.5km'));
    });

    test('formattedDuration returns minutes', () {
      final route = Route(
        coordinates: const [],
        distanceInMeters: 1000,
        durationInMillis: 600000,
      );

      expect(route.formattedDuration, equals('10분'));
    });

    test('formattedDuration returns hours and minutes for long duration', () {
      final route = Route(
        coordinates: const [],
        distanceInMeters: 10000,
        durationInMillis: 3900000,
      );

      expect(route.formattedDuration, equals('1시간 5분'));
    });
  });
}
