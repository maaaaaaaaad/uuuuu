import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';

void main() {
  group('CreateReservationParams', () {
    test('should create params with all fields', () {
      const params = CreateReservationParams(
        shopId: 'shop-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        memo: '첫 방문입니다',
      );

      expect(params.shopId, 'shop-1');
      expect(params.treatmentId, 'treatment-1');
      expect(params.reservationDate, '2025-06-15');
      expect(params.startTime, '14:00');
      expect(params.memo, '첫 방문입니다');
    });

    test('should create params without memo', () {
      const params = CreateReservationParams(
        shopId: 'shop-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
      );

      expect(params.memo, isNull);
    });

    test('should be equal when all fields are the same', () {
      const params1 = CreateReservationParams(
        shopId: 'shop-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        memo: 'memo',
      );

      const params2 = CreateReservationParams(
        shopId: 'shop-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        memo: 'memo',
      );

      expect(params1, equals(params2));
    });

    test('should not be equal when fields differ', () {
      const params1 = CreateReservationParams(
        shopId: 'shop-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
      );

      const params2 = CreateReservationParams(
        shopId: 'shop-2',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
