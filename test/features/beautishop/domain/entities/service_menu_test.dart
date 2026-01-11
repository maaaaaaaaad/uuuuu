import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';

void main() {
  group('ServiceMenu', () {
    test('should create ServiceMenu with required fields', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
      );

      expect(menu.id, '1');
      expect(menu.name, '젤네일 기본');
      expect(menu.price, 50000);
    });

    test('should have optional duration field', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        durationMinutes: 60,
      );

      expect(menu.durationMinutes, 60);
    });

    test('should have optional description field', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        description: '기본 젤네일 시술입니다. 단색 컬러 포함.',
      );

      expect(menu.description, '기본 젤네일 시술입니다. 단색 컬러 포함.');
    });

    test('should have optional category field', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        category: '네일',
      );

      expect(menu.category, '네일');
    });

    test('should have optional discountPrice field', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        discountPrice: 40000,
      );

      expect(menu.discountPrice, 40000);
      expect(menu.hasDiscount, isTrue);
    });

    test('hasDiscount should be false when no discount price', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
      );

      expect(menu.hasDiscount, isFalse);
    });

    test('should format price with comma separator', () {
      const menu = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
      );

      expect(menu.formattedPrice, '50,000원');
    });

    test('should format duration as hours and minutes', () {
      const menu1 = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
        durationMinutes: 60,
      );

      const menu2 = ServiceMenu(
        id: '2',
        name: '풀세트',
        price: 150000,
        durationMinutes: 150,
      );

      expect(menu1.formattedDuration, '1시간');
      expect(menu2.formattedDuration, '2시간 30분');
    });

    test('should support equality comparison', () {
      const menu1 = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
      );

      const menu2 = ServiceMenu(
        id: '1',
        name: '젤네일 기본',
        price: 50000,
      );

      expect(menu1, equals(menu2));
    });
  });
}
