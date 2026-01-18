import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/data/models/directions_response_model.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';

void main() {
  group('DirectionsResponseModel', () {
    final successResponseJson = {
      'code': 0,
      'message': 'success',
      'route': {
        'traoptimal': [
          {
            'path': [
              [127.123, 37.456],
              [127.124, 37.457],
              [127.125, 37.458],
            ],
            'summary': {
              'distance': 1234,
              'duration': 600000,
            },
          },
        ],
      },
    };

    final errorResponseJson = {
      'code': 1,
      'message': 'Route not found',
      'route': null,
    };

    final noRouteResponseJson = {
      'code': 0,
      'message': 'success',
      'route': {
        'traoptimal': [],
      },
    };

    group('fromJson', () {
      test('parses success response correctly', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);

        expect(model.code, equals(0));
        expect(model.message, equals('success'));
        expect(model.isSuccess, isTrue);
      });

      test('parses path coordinates correctly', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);

        expect(model.coordinates, isNotNull);
        expect(model.coordinates!.length, equals(3));
      });

      test('converts coordinates from lng,lat to LatLng (lat,lng)', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);

        final firstCoord = model.coordinates!.first;
        expect(firstCoord.longitude, equals(127.123));
        expect(firstCoord.latitude, equals(37.456));
      });

      test('parses distance correctly', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);

        expect(model.distanceInMeters, equals(1234));
      });

      test('parses duration correctly', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);

        expect(model.durationInMillis, equals(600000));
      });

      test('parses error response correctly', () {
        final model = DirectionsResponseModel.fromJson(errorResponseJson);

        expect(model.code, equals(1));
        expect(model.message, equals('Route not found'));
        expect(model.isSuccess, isFalse);
      });

      test('returns null coordinates for error response', () {
        final model = DirectionsResponseModel.fromJson(errorResponseJson);

        expect(model.coordinates, isNull);
        expect(model.distanceInMeters, isNull);
        expect(model.durationInMillis, isNull);
      });

      test('handles empty traoptimal array', () {
        final model = DirectionsResponseModel.fromJson(noRouteResponseJson);

        expect(model.code, equals(0));
        expect(model.coordinates, isNull);
      });
    });

    group('toRoute', () {
      test('converts to Route entity on success', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);
        final route = model.toRoute();

        expect(route, isNotNull);
        expect(route, isA<Route>());
        expect(route!.coordinates.length, equals(3));
        expect(route.distanceInMeters, equals(1234));
        expect(route.durationInMillis, equals(600000));
      });

      test('returns null when no route available', () {
        final model = DirectionsResponseModel.fromJson(errorResponseJson);
        final route = model.toRoute();

        expect(route, isNull);
      });

      test('preserves coordinate order in Route', () {
        final model = DirectionsResponseModel.fromJson(successResponseJson);
        final route = model.toRoute();

        expect(route!.coordinates.first.latitude, equals(37.456));
        expect(route.coordinates.first.longitude, equals(127.123));
        expect(route.coordinates.last.latitude, equals(37.458));
        expect(route.coordinates.last.longitude, equals(127.125));
      });
    });
  });
}
