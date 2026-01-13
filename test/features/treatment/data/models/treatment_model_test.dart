import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/treatment/data/models/treatment_model.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';

void main() {
  group('TreatmentModel', () {
    final testJson = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'shopId': '660e8400-e29b-41d4-a716-446655440000',
      'name': '젤네일 풀세트',
      'price': 50000,
      'duration': 90,
      'description': '고급 젤네일 풀세트 시술입니다.',
      'createdAt': '2025-01-01T00:00:00Z',
      'updatedAt': '2025-01-10T00:00:00Z',
    };

    test('extends ServiceMenu', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model, isA<ServiceMenu>());
    });

    test('fromJson parses id correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.id, equals('550e8400-e29b-41d4-a716-446655440000'));
    });

    test('fromJson parses shopId correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.shopId, equals('660e8400-e29b-41d4-a716-446655440000'));
    });

    test('fromJson parses name correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.name, equals('젤네일 풀세트'));
    });

    test('fromJson parses price correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.price, equals(50000));
    });

    test('fromJson parses duration as durationMinutes', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.durationMinutes, equals(90));
    });

    test('fromJson parses description correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.description, equals('고급 젤네일 풀세트 시술입니다.'));
    });

    test('fromJson parses createdAt correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.createdAt, isA<DateTime>());
      expect(model.createdAt.year, equals(2025));
    });

    test('fromJson parses updatedAt correctly', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.updatedAt, isA<DateTime>());
    });

    test('fromJson handles null description', () {
      final jsonWithNullDescription = Map<String, dynamic>.from(testJson);
      jsonWithNullDescription['description'] = null;
      final model = TreatmentModel.fromJson(jsonWithNullDescription);
      expect(model.description, isNull);
    });

    test('toJson converts model back to JSON', () {
      final model = TreatmentModel.fromJson(testJson);
      final json = model.toJson();
      expect(json['id'], equals(model.id));
      expect(json['shopId'], equals(model.shopId));
      expect(json['name'], equals(model.name));
      expect(json['price'], equals(model.price));
      expect(json['duration'], equals(model.durationMinutes));
    });

    test('formattedPrice returns correctly formatted string', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.formattedPrice, equals('50,000원'));
    });

    test('formattedDuration returns correctly formatted string', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.formattedDuration, equals('1시간 30분'));
    });

    test('category is null by default', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.category, isNull);
    });

    test('discountPrice is null by default', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.discountPrice, isNull);
    });

    test('hasDiscount is false by default', () {
      final model = TreatmentModel.fromJson(testJson);
      expect(model.hasDiscount, isFalse);
    });
  });
}
