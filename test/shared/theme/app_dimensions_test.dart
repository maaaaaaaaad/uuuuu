import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/shared/theme/app_dimensions.dart';

void main() {
  group('AppDimensions', () {
    group('Border Radius', () {
      test('radiusSmall should be 12.0', () {
        expect(AppDimensions.radiusSmall, 12.0);
      });

      test('radiusMedium should be 20.0', () {
        expect(AppDimensions.radiusMedium, 20.0);
      });

      test('radiusLarge should be 30.0', () {
        expect(AppDimensions.radiusLarge, 30.0);
      });

      test('radiusPill should be 50.0', () {
        expect(AppDimensions.radiusPill, 50.0);
      });
    });
  });
}
