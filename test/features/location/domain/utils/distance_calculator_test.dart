import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/utils/distance_calculator.dart';

void main() {
  group('calculateDistanceKm', () {
    test('returns 0 for same coordinates', () {
      final result = calculateDistanceKm(
        37.5172,
        127.0473,
        37.5172,
        127.0473,
      );

      expect(result, 0.0);
    });

    test('calculates distance between Seoul Station and Gangnam Station', () {
      const seoulStationLat = 37.5547;
      const seoulStationLng = 126.9707;
      const gangnamStationLat = 37.4979;
      const gangnamStationLng = 127.0276;

      final result = calculateDistanceKm(
        seoulStationLat,
        seoulStationLng,
        gangnamStationLat,
        gangnamStationLng,
      );

      expect(result, closeTo(7.8, 0.5));
    });

    test('calculates short distance (under 1km)', () {
      const lat1 = 37.5172;
      const lng1 = 127.0473;
      const lat2 = 37.5182;
      const lng2 = 127.0483;

      final result = calculateDistanceKm(lat1, lng1, lat2, lng2);

      expect(result, lessThan(1.0));
      expect(result, greaterThan(0.0));
    });

    test('calculates distance with reversed coordinates (symmetric)', () {
      const lat1 = 37.5547;
      const lng1 = 126.9707;
      const lat2 = 37.4979;
      const lng2 = 127.0276;

      final forward = calculateDistanceKm(lat1, lng1, lat2, lng2);
      final reverse = calculateDistanceKm(lat2, lng2, lat1, lng1);

      expect(forward, closeTo(reverse, 0.001));
    });

    test('calculates long distance (Seoul to Busan)', () {
      const seoulLat = 37.5665;
      const seoulLng = 126.9780;
      const busanLat = 35.1796;
      const busanLng = 129.0756;

      final result = calculateDistanceKm(seoulLat, seoulLng, busanLat, busanLng);

      expect(result, closeTo(325, 10));
    });
  });
}
