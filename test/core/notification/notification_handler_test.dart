import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/notification/notification_handler.dart';

void main() {
  group('NotificationHandler', () {

    group('parsePayload', () {
      test('returns empty map for null payload', () {
        final result = NotificationHandler.parsePayload(null);
        expect(result, isEmpty);
      });

      test('returns empty map for invalid JSON', () {
        final result = NotificationHandler.parsePayload('not json');
        expect(result, isEmpty);
      });

      test('parses valid JSON payload', () {
        final payload = jsonEncode({
          'type': 'RESERVATION_CONFIRMED',
          'reservationId': 'abc-123',
        });
        final result = NotificationHandler.parsePayload(payload);
        expect(result['type'], 'RESERVATION_CONFIRMED');
        expect(result['reservationId'], 'abc-123');
      });
    });

    group('buildPayload', () {
      test('encodes data map with type and reservationId', () {
        final data = {'type': 'RESERVATION_CONFIRMED', 'reservationId': 'abc'};
        final payload = NotificationHandler.buildPayload(data);
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        expect(decoded['type'], 'RESERVATION_CONFIRMED');
        expect(decoded['reservationId'], 'abc');
      });
    });

    group('shouldNavigateToDetail', () {
      test('returns true for RESERVATION_CONFIRMED', () {
        expect(
          NotificationHandler.shouldNavigateToDetail('RESERVATION_CONFIRMED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_REJECTED', () {
        expect(
          NotificationHandler.shouldNavigateToDetail('RESERVATION_REJECTED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_COMPLETED', () {
        expect(
          NotificationHandler.shouldNavigateToDetail('RESERVATION_COMPLETED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_NO_SHOW', () {
        expect(
          NotificationHandler.shouldNavigateToDetail('RESERVATION_NO_SHOW'),
          isTrue,
        );
      });

      test('returns false for unknown type', () {
        expect(
          NotificationHandler.shouldNavigateToDetail('UNKNOWN'),
          isFalse,
        );
      });

      test('returns false for null type', () {
        expect(
          NotificationHandler.shouldNavigateToDetail(null),
          isFalse,
        );
      });
    });
  });
}
