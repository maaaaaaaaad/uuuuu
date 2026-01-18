import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/location/domain/entities/route.dart';
import 'package:jellomark/features/location/domain/repositories/directions_repository.dart';
import 'package:jellomark/features/location/presentation/providers/location_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectionsRepository extends Mock implements DirectionsRepository {}

void main() {
  group('RouteParams', () {
    test('should create RouteParams with correct values', () {
      const params = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );

      expect(params.startLat, 37.5665);
      expect(params.startLng, 126.9780);
      expect(params.endLat, 37.5700);
      expect(params.endLng, 126.9800);
    });

    test('should be equal when values are same', () {
      const params1 = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );
      const params2 = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('should not be equal when values differ', () {
      const params1 = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );
      const params2 = RouteParams(
        startLat: 37.5666,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );

      expect(params1, isNot(equals(params2)));
    });
  });

  group('routeProvider', () {
    late MockDirectionsRepository mockRepository;

    setUp(() {
      mockRepository = MockDirectionsRepository();
    });

    test('should return Route when repository succeeds', () async {
      const testRoute = Route(
        coordinates: [
          LatLng(latitude: 37.5665, longitude: 126.9780),
          LatLng(latitude: 37.5700, longitude: 126.9800),
        ],
        distanceInMeters: 500,
        durationInMillis: 300000,
      );

      when(() => mockRepository.getRoute(
            startLat: 37.5665,
            startLng: 126.9780,
            endLat: 37.5700,
            endLng: 126.9800,
          )).thenAnswer((_) async => const Right(testRoute));

      final container = ProviderContainer(
        overrides: [
          directionsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      addTearDown(container.dispose);

      const params = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );

      final result = await container.read(routeProvider(params).future);

      expect(result, equals(testRoute));
      verify(() => mockRepository.getRoute(
            startLat: 37.5665,
            startLng: 126.9780,
            endLat: 37.5700,
            endLng: 126.9800,
          )).called(1);
    });

    test('should return null when repository fails', () async {
      when(() => mockRepository.getRoute(
            startLat: any(named: 'startLat'),
            startLng: any(named: 'startLng'),
            endLat: any(named: 'endLat'),
            endLng: any(named: 'endLng'),
          )).thenAnswer(
          (_) async => const Left(ServerFailure('Route not found')));

      final container = ProviderContainer(
        overrides: [
          directionsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      addTearDown(container.dispose);

      const params = RouteParams(
        startLat: 37.5665,
        startLng: 126.9780,
        endLat: 37.5700,
        endLng: 126.9800,
      );

      final result = await container.read(routeProvider(params).future);

      expect(result, isNull);
    });
  });
}
