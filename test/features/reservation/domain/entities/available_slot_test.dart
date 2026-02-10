import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';

void main() {
  group('AvailableSlot', () {
    const tSlot = AvailableSlot(startTime: '10:00', available: true);

    test('should create with required fields', () {
      expect(tSlot.startTime, '10:00');
      expect(tSlot.available, true);
    });

    test('should be equal when all fields are the same', () {
      const other = AvailableSlot(startTime: '10:00', available: true);
      expect(tSlot, equals(other));
    });

    test('should not be equal when fields differ', () {
      const other = AvailableSlot(startTime: '10:00', available: false);
      expect(tSlot, isNot(equals(other)));
    });

    test('should not be equal when startTime differs', () {
      const other = AvailableSlot(startTime: '10:30', available: true);
      expect(tSlot, isNot(equals(other)));
    });
  });
}
