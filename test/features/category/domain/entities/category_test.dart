import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('creates instance with required fields', () {
      const category = Category(
        id: 'cat-1',
        name: '헤어',
      );

      expect(category.id, equals('cat-1'));
      expect(category.name, equals('헤어'));
    });

    test('equality works correctly', () {
      const category1 = Category(id: 'cat-1', name: '헤어');
      const category2 = Category(id: 'cat-1', name: '헤어');

      expect(category1, equals(category2));
    });

    test('different id creates unequal instances', () {
      const category1 = Category(id: 'cat-1', name: '헤어');
      const category2 = Category(id: 'cat-2', name: '헤어');

      expect(category1, isNot(equals(category2)));
    });

    test('different name creates unequal instances', () {
      const category1 = Category(id: 'cat-1', name: '헤어');
      const category2 = Category(id: 'cat-1', name: '네일');

      expect(category1, isNot(equals(category2)));
    });
  });
}
