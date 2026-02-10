import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';

void main() {
  group('AvailableSlotsResult', () {
    const tSlots = [
      AvailableSlot(startTime: '10:00', available: true),
      AvailableSlot(startTime: '10:30', available: false),
    ];

    const tResult = AvailableSlotsResult(
      date: '2025-06-15',
      openTime: '10:00',
      closeTime: '20:00',
      slots: tSlots,
    );

    test('should create with required fields', () {
      expect(tResult.date, '2025-06-15');
      expect(tResult.openTime, '10:00');
      expect(tResult.closeTime, '20:00');
      expect(tResult.slots.length, 2);
      expect(tResult.slots[0].available, true);
      expect(tResult.slots[1].available, false);
    });

    test('should be equal when all fields are the same', () {
      const other = AvailableSlotsResult(
        date: '2025-06-15',
        openTime: '10:00',
        closeTime: '20:00',
        slots: tSlots,
      );
      expect(tResult, equals(other));
    });

    test('should not be equal when fields differ', () {
      const other = AvailableSlotsResult(
        date: '2025-06-16',
        openTime: '10:00',
        closeTime: '20:00',
        slots: tSlots,
      );
      expect(tResult, isNot(equals(other)));
    });

    test('should support empty slots', () {
      const empty = AvailableSlotsResult(
        date: '2025-06-15',
        openTime: '10:00',
        closeTime: '20:00',
        slots: [],
      );
      expect(empty.slots, isEmpty);
    });
  });
}
