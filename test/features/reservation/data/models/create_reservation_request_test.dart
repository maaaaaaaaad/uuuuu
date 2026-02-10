import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/data/models/create_reservation_request.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';

void main() {
  group('CreateReservationRequest', () {
    group('toJson', () {
      test('should include all fields when memo is present', () {
        const request = CreateReservationRequest(
          shopId: 'shop-1',
          treatmentId: 'treatment-1',
          reservationDate: '2025-06-15',
          startTime: '14:00',
          memo: '첫 방문입니다',
        );

        final json = request.toJson();

        expect(json['shopId'], 'shop-1');
        expect(json['treatmentId'], 'treatment-1');
        expect(json['reservationDate'], '2025-06-15');
        expect(json['startTime'], '14:00');
        expect(json['memo'], '첫 방문입니다');
      });

      test('should exclude memo when null', () {
        const request = CreateReservationRequest(
          shopId: 'shop-1',
          treatmentId: 'treatment-1',
          reservationDate: '2025-06-15',
          startTime: '14:00',
        );

        final json = request.toJson();

        expect(json.containsKey('memo'), false);
      });
    });

    group('fromParams', () {
      test('should create request from params with memo', () {
        const params = CreateReservationParams(
          shopId: 'shop-1',
          treatmentId: 'treatment-1',
          reservationDate: '2025-06-15',
          startTime: '14:00',
          memo: '메모',
        );

        final request = CreateReservationRequest.fromParams(params);

        expect(request.shopId, 'shop-1');
        expect(request.treatmentId, 'treatment-1');
        expect(request.reservationDate, '2025-06-15');
        expect(request.startTime, '14:00');
        expect(request.memo, '메모');
      });

      test('should create request from params without memo', () {
        const params = CreateReservationParams(
          shopId: 'shop-1',
          treatmentId: 'treatment-1',
          reservationDate: '2025-06-15',
          startTime: '14:00',
        );

        final request = CreateReservationRequest.fromParams(params);

        expect(request.memo, isNull);
      });
    });
  });
}
