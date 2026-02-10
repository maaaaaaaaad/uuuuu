import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

void main() {
  group('Reservation', () {
    final tReservation = Reservation(
      id: 'res-1',
      shopId: 'shop-1',
      memberId: 'member-1',
      treatmentId: 'treatment-1',
      shopName: '젤로네일',
      treatmentName: '젤네일',
      treatmentPrice: 30000,
      treatmentDuration: 60,
      memberNickname: '홍길동',
      reservationDate: '2025-06-15',
      startTime: '14:00',
      endTime: '15:00',
      status: ReservationStatus.pending,
      memo: '첫 방문입니다',
      createdAt: DateTime(2025, 6, 10, 10, 30),
      updatedAt: DateTime(2025, 6, 10, 10, 30),
    );

    test('should create Reservation with all fields', () {
      expect(tReservation.id, 'res-1');
      expect(tReservation.shopId, 'shop-1');
      expect(tReservation.memberId, 'member-1');
      expect(tReservation.treatmentId, 'treatment-1');
      expect(tReservation.shopName, '젤로네일');
      expect(tReservation.treatmentName, '젤네일');
      expect(tReservation.treatmentPrice, 30000);
      expect(tReservation.treatmentDuration, 60);
      expect(tReservation.memberNickname, '홍길동');
      expect(tReservation.reservationDate, '2025-06-15');
      expect(tReservation.startTime, '14:00');
      expect(tReservation.endTime, '15:00');
      expect(tReservation.status, ReservationStatus.pending);
      expect(tReservation.memo, '첫 방문입니다');
      expect(tReservation.rejectionReason, isNull);
    });

    test('should support nullable fields', () {
      final reservation = Reservation(
        id: 'res-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.pending,
        createdAt: DateTime(2025, 6, 10),
        updatedAt: DateTime(2025, 6, 10),
      );

      expect(reservation.shopName, isNull);
      expect(reservation.treatmentName, isNull);
      expect(reservation.treatmentPrice, isNull);
      expect(reservation.treatmentDuration, isNull);
      expect(reservation.memberNickname, isNull);
      expect(reservation.memo, isNull);
      expect(reservation.rejectionReason, isNull);
    });

    test('should be equal when all fields are the same', () {
      final other = Reservation(
        id: 'res-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        shopName: '젤로네일',
        treatmentName: '젤네일',
        treatmentPrice: 30000,
        treatmentDuration: 60,
        memberNickname: '홍길동',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.pending,
        memo: '첫 방문입니다',
        createdAt: DateTime(2025, 6, 10, 10, 30),
        updatedAt: DateTime(2025, 6, 10, 10, 30),
      );

      expect(tReservation, equals(other));
    });

    test('should not be equal when fields differ', () {
      final other = Reservation(
        id: 'res-2',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        reservationDate: '2025-06-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.pending,
        createdAt: DateTime(2025, 6, 10),
        updatedAt: DateTime(2025, 6, 10),
      );

      expect(tReservation, isNot(equals(other)));
    });
  });
}
