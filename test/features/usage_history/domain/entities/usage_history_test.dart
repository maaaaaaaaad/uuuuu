import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';

void main() {
  final tUsageHistory = UsageHistory(
    id: 'uh-1',
    memberId: 'member-1',
    shopId: 'shop-1',
    reservationId: 'reservation-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    completedAt: DateTime(2026, 1, 15, 14, 0),
    createdAt: DateTime(2026, 1, 15, 14, 0),
  );

  group('UsageHistory', () {
    test('should create with all fields', () {
      expect(tUsageHistory.id, 'uh-1');
      expect(tUsageHistory.shopName, '젤로네일');
      expect(tUsageHistory.treatmentName, '젤네일');
      expect(tUsageHistory.treatmentPrice, 30000);
      expect(tUsageHistory.treatmentDuration, 60);
    });

    test('should be equal when all fields are the same', () {
      final copy = UsageHistory(
        id: 'uh-1',
        memberId: 'member-1',
        shopId: 'shop-1',
        reservationId: 'reservation-1',
        shopName: '젤로네일',
        treatmentName: '젤네일',
        treatmentPrice: 30000,
        treatmentDuration: 60,
        completedAt: DateTime(2026, 1, 15, 14, 0),
        createdAt: DateTime(2026, 1, 15, 14, 0),
      );

      expect(tUsageHistory, copy);
    });

    test('should not be equal when fields differ', () {
      final different = UsageHistory(
        id: 'uh-2',
        memberId: 'member-1',
        shopId: 'shop-1',
        reservationId: 'reservation-1',
        shopName: '젤로네일',
        treatmentName: '젤네일',
        treatmentPrice: 30000,
        treatmentDuration: 60,
        completedAt: DateTime(2026, 1, 15, 14, 0),
        createdAt: DateTime(2026, 1, 15, 14, 0),
      );

      expect(tUsageHistory, isNot(different));
    });
  });
}
