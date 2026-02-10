import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/data/models/available_slot_model.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';

void main() {
  group('AvailableSlotModel', () {
    const tModel = AvailableSlotModel(startTime: '10:00', available: true);

    final tJson = {'startTime': '10:00', 'available': true};

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final result = AvailableSlotModel.fromJson(tJson);

        expect(result.startTime, '10:00');
        expect(result.available, true);
      });

      test('should handle unavailable slot', () {
        final json = {'startTime': '11:00', 'available': false};

        final result = AvailableSlotModel.fromJson(json);

        expect(result.startTime, '11:00');
        expect(result.available, false);
      });
    });

    group('toEntity', () {
      test('should convert to AvailableSlot entity', () {
        final entity = tModel.toEntity();

        expect(entity, isA<AvailableSlot>());
        expect(entity.startTime, '10:00');
        expect(entity.available, true);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields are the same', () {
        const other = AvailableSlotModel(startTime: '10:00', available: true);
        expect(tModel, equals(other));
      });
    });
  });
}
