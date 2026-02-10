import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/usage_history/data/models/usage_history_model.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';

void main() {
  group('UsageHistoryModel', () {
    final tJson = {
      'id': 'uh-1',
      'memberId': 'member-1',
      'shopId': 'shop-1',
      'reservationId': 'reservation-1',
      'shopName': '젤로네일',
      'treatmentName': '젤네일',
      'treatmentPrice': 30000,
      'treatmentDuration': 60,
      'completedAt': '2026-01-15T14:00:00Z',
      'createdAt': '2026-01-15T14:00:00Z',
    };

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final model = UsageHistoryModel.fromJson(tJson);

        expect(model.id, 'uh-1');
        expect(model.shopName, '젤로네일');
        expect(model.treatmentName, '젤네일');
        expect(model.treatmentPrice, 30000);
        expect(model.treatmentDuration, 60);
      });

      test('should parse completedAt correctly', () {
        final model = UsageHistoryModel.fromJson(tJson);

        expect(model.completedAt, DateTime.utc(2026, 1, 15, 14, 0));
      });
    });

    group('toEntity', () {
      test('should convert to UsageHistory entity', () {
        final model = UsageHistoryModel.fromJson(tJson);
        final entity = model.toEntity();

        expect(entity, isA<UsageHistory>());
        expect(entity.id, 'uh-1');
        expect(entity.shopName, '젤로네일');
        expect(entity.treatmentPrice, 30000);
      });
    });
  });
}
