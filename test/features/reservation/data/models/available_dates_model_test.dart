import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/data/models/available_dates_model.dart';

void main() {
  group('AvailableDatesModel', () {
    const tModel = AvailableDatesModel(
      availableDates: ['2025-06-15', '2025-06-16', '2025-06-17'],
    );

    final tJson = {
      'availableDates': ['2025-06-15', '2025-06-16', '2025-06-17'],
    };

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final result = AvailableDatesModel.fromJson(tJson);

        expect(result.availableDates.length, 3);
        expect(result.availableDates[0], '2025-06-15');
        expect(result.availableDates[1], '2025-06-16');
        expect(result.availableDates[2], '2025-06-17');
      });

      test('should handle empty dates list', () {
        final json = {'availableDates': <String>[]};

        final result = AvailableDatesModel.fromJson(json);

        expect(result.availableDates, isEmpty);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields are the same', () {
        const other = AvailableDatesModel(
          availableDates: ['2025-06-15', '2025-06-16', '2025-06-17'],
        );
        expect(tModel, equals(other));
      });
    });
  });
}
