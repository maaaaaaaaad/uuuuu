import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/data/models/available_slot_model.dart';
import 'package:jellomark/features/reservation/data/models/available_slots_result_model.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';

void main() {
  group('AvailableSlotsResultModel', () {
    const tModel = AvailableSlotsResultModel(
      date: '2025-06-15',
      openTime: '10:00',
      closeTime: '20:00',
      slots: [
        AvailableSlotModel(startTime: '10:00', available: true),
        AvailableSlotModel(startTime: '10:30', available: false),
      ],
    );

    final tJson = {
      'date': '2025-06-15',
      'openTime': '10:00',
      'closeTime': '20:00',
      'slots': [
        {'startTime': '10:00', 'available': true},
        {'startTime': '10:30', 'available': false},
      ],
    };

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final result = AvailableSlotsResultModel.fromJson(tJson);

        expect(result.date, '2025-06-15');
        expect(result.openTime, '10:00');
        expect(result.closeTime, '20:00');
        expect(result.slots.length, 2);
        expect(result.slots[0].startTime, '10:00');
        expect(result.slots[0].available, true);
        expect(result.slots[1].startTime, '10:30');
        expect(result.slots[1].available, false);
      });

      test('should handle empty slots list', () {
        final json = {
          'date': '2025-06-15',
          'openTime': '10:00',
          'closeTime': '20:00',
          'slots': <Map<String, dynamic>>[],
        };

        final result = AvailableSlotsResultModel.fromJson(json);

        expect(result.slots, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert to AvailableSlotsResult entity', () {
        final entity = tModel.toEntity();

        expect(entity, isA<AvailableSlotsResult>());
        expect(entity.date, '2025-06-15');
        expect(entity.openTime, '10:00');
        expect(entity.closeTime, '20:00');
        expect(entity.slots.length, 2);
        expect(entity.slots[0].startTime, '10:00');
        expect(entity.slots[0].available, true);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields are the same', () {
        const other = AvailableSlotsResultModel(
          date: '2025-06-15',
          openTime: '10:00',
          closeTime: '20:00',
          slots: [
            AvailableSlotModel(startTime: '10:00', available: true),
            AvailableSlotModel(startTime: '10:30', available: false),
          ],
        );
        expect(tModel, equals(other));
      });
    });
  });
}
