import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/location/domain/entities/user_location.dart';

void main() {
  group('UserLocation', () {
    test('should create UserLocation with latitude and longitude', () {
      const location = UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(location.latitude, 37.5665);
      expect(location.longitude, 126.9780);
    });

    test('two UserLocations with same values should be equal', () {
      const location1 = UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
      );
      const location2 = UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(location1, equals(location2));
    });

    test('two UserLocations with different values should not be equal', () {
      const location1 = UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
      );
      const location2 = UserLocation(
        latitude: 35.1796,
        longitude: 129.0756,
      );

      expect(location1, isNot(equals(location2)));
    });

    test('props should contain latitude and longitude', () {
      const location = UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
      );

      expect(location.props, [37.5665, 126.9780]);
    });
  });
}
