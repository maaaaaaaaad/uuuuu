import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/data/models/reservation_model.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

void main() {
  group('ReservationModel', () {
    const tModel = ReservationModel(
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
      status: 'PENDING',
      memo: '첫 방문입니다',
      createdAt: '2025-06-10T10:30:00Z',
      updatedAt: '2025-06-10T10:30:00Z',
    );

    final tJson = {
      'id': 'res-1',
      'shopId': 'shop-1',
      'memberId': 'member-1',
      'treatmentId': 'treatment-1',
      'shopName': '젤로네일',
      'treatmentName': '젤네일',
      'treatmentPrice': 30000,
      'treatmentDuration': 60,
      'memberNickname': '홍길동',
      'reservationDate': '2025-06-15',
      'startTime': '14:00',
      'endTime': '15:00',
      'status': 'PENDING',
      'memo': '첫 방문입니다',
      'rejectionReason': null,
      'createdAt': '2025-06-10T10:30:00Z',
      'updatedAt': '2025-06-10T10:30:00Z',
    };

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final result = ReservationModel.fromJson(tJson);

        expect(result.id, 'res-1');
        expect(result.shopId, 'shop-1');
        expect(result.memberId, 'member-1');
        expect(result.treatmentId, 'treatment-1');
        expect(result.shopName, '젤로네일');
        expect(result.treatmentName, '젤네일');
        expect(result.treatmentPrice, 30000);
        expect(result.treatmentDuration, 60);
        expect(result.memberNickname, '홍길동');
        expect(result.reservationDate, '2025-06-15');
        expect(result.startTime, '14:00');
        expect(result.endTime, '15:00');
        expect(result.status, 'PENDING');
        expect(result.memo, '첫 방문입니다');
        expect(result.rejectionReason, isNull);
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'res-2',
          'shopId': 'shop-1',
          'memberId': 'member-1',
          'treatmentId': 'treatment-1',
          'reservationDate': '2025-06-15',
          'startTime': '14:00',
          'endTime': '15:00',
          'status': 'CONFIRMED',
          'createdAt': '2025-06-10T10:30:00Z',
          'updatedAt': '2025-06-10T10:30:00Z',
        };

        final result = ReservationModel.fromJson(json);

        expect(result.shopName, isNull);
        expect(result.treatmentName, isNull);
        expect(result.treatmentPrice, isNull);
        expect(result.treatmentDuration, isNull);
        expect(result.memberNickname, isNull);
        expect(result.memo, isNull);
        expect(result.rejectionReason, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map', () {
        final result = tModel.toJson();

        expect(result['id'], 'res-1');
        expect(result['shopId'], 'shop-1');
        expect(result['status'], 'PENDING');
        expect(result['memo'], '첫 방문입니다');
        expect(result['createdAt'], '2025-06-10T10:30:00Z');
      });
    });

    group('toEntity', () {
      test('should convert to Reservation entity', () {
        final entity = tModel.toEntity();

        expect(entity, isA<Reservation>());
        expect(entity.id, 'res-1');
        expect(entity.shopId, 'shop-1');
        expect(entity.status, ReservationStatus.pending);
        expect(entity.createdAt, DateTime.utc(2025, 6, 10, 10, 30));
        expect(entity.updatedAt, DateTime.utc(2025, 6, 10, 10, 30));
        expect(entity.shopName, '젤로네일');
        expect(entity.treatmentPrice, 30000);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields are the same', () {
        const other = ReservationModel(
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
          status: 'PENDING',
          memo: '첫 방문입니다',
          createdAt: '2025-06-10T10:30:00Z',
          updatedAt: '2025-06-10T10:30:00Z',
        );

        expect(tModel, equals(other));
      });
    });
  });
}
