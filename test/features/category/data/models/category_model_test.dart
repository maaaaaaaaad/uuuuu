import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/category/data/models/category_model.dart';
import 'package:jellomark/features/category/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    final testJson = {
      'id': 'cat-1',
      'name': '헤어',
    };

    test('extends Category', () {
      final model = CategoryModel.fromJson(testJson);
      expect(model, isA<Category>());
    });

    test('fromJson parses id correctly', () {
      final model = CategoryModel.fromJson(testJson);
      expect(model.id, equals('cat-1'));
    });

    test('fromJson parses name correctly', () {
      final model = CategoryModel.fromJson(testJson);
      expect(model.name, equals('헤어'));
    });

    test('toJson converts model back to JSON', () {
      final model = CategoryModel.fromJson(testJson);
      final json = model.toJson();
      expect(json['id'], equals('cat-1'));
      expect(json['name'], equals('헤어'));
    });
  });
}
