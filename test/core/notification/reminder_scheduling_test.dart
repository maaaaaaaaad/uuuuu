import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/notification/notification_handler.dart';

void main() {
  group('NotificationHandler reminder logic', () {
    group('computeReminderTime', () {
      test('returns 3 hours before reservation time', () {
        final reservationTime = DateTime(2025, 6, 15, 14, 0);
        final result = NotificationHandler.computeReminderTime(reservationTime);
        expect(result, DateTime(2025, 6, 15, 11, 0));
      });

      test('handles midnight crossing', () {
        final reservationTime = DateTime(2025, 6, 15, 2, 0);
        final result = NotificationHandler.computeReminderTime(reservationTime);
        expect(result, DateTime(2025, 6, 14, 23, 0));
      });
    });

    group('shouldScheduleReminder', () {
      test('returns true when reminder time is in the future', () {
        final reminderTime = DateTime.now().add(const Duration(hours: 1));
        expect(
          NotificationHandler.shouldScheduleReminder(reminderTime),
          isTrue,
        );
      });

      test('returns false when reminder time is in the past', () {
        final reminderTime = DateTime.now().subtract(const Duration(hours: 1));
        expect(
          NotificationHandler.shouldScheduleReminder(reminderTime),
          isFalse,
        );
      });
    });

    group('parseReservationDateTime', () {
      test('parses valid date and time', () {
        final result = NotificationHandler.parseReservationDateTime(
          '2025-06-15',
          '14:00',
        );
        expect(result, DateTime(2025, 6, 15, 14, 0));
      });

      test('parses time with seconds', () {
        final result = NotificationHandler.parseReservationDateTime(
          '2025-06-15',
          '14:30:00',
        );
        expect(result, DateTime(2025, 6, 15, 14, 30));
      });

      test('returns null for null date', () {
        final result = NotificationHandler.parseReservationDateTime(
          null,
          '14:00',
        );
        expect(result, isNull);
      });

      test('returns null for null time', () {
        final result = NotificationHandler.parseReservationDateTime(
          '2025-06-15',
          null,
        );
        expect(result, isNull);
      });

      test('returns null for invalid date format', () {
        final result = NotificationHandler.parseReservationDateTime(
          'not-a-date',
          '14:00',
        );
        expect(result, isNull);
      });

      test('returns null for invalid time format', () {
        final result = NotificationHandler.parseReservationDateTime(
          '2025-06-15',
          'not-a-time',
        );
        expect(result, isNull);
      });
    });

    group('reminderNotificationId', () {
      test('returns consistent id for same reservationId', () {
        final id1 = NotificationHandler.reminderNotificationId('abc-123');
        final id2 = NotificationHandler.reminderNotificationId('abc-123');
        expect(id1, id2);
      });

      test('returns different ids for different reservationIds', () {
        final id1 = NotificationHandler.reminderNotificationId('abc-123');
        final id2 = NotificationHandler.reminderNotificationId('def-456');
        expect(id1, isNot(id2));
      });
    });

    group('shouldCancelReminder', () {
      test('returns true for RESERVATION_REJECTED', () {
        expect(
          NotificationHandler.shouldCancelReminder('RESERVATION_REJECTED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_CANCELLED', () {
        expect(
          NotificationHandler.shouldCancelReminder('RESERVATION_CANCELLED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_NO_SHOW', () {
        expect(
          NotificationHandler.shouldCancelReminder('RESERVATION_NO_SHOW'),
          isTrue,
        );
      });

      test('returns false for RESERVATION_CONFIRMED', () {
        expect(
          NotificationHandler.shouldCancelReminder('RESERVATION_CONFIRMED'),
          isFalse,
        );
      });

      test('returns false for RESERVATION_CREATED', () {
        expect(
          NotificationHandler.shouldCancelReminder('RESERVATION_CREATED'),
          isFalse,
        );
      });

      test('returns false for null type', () {
        expect(
          NotificationHandler.shouldCancelReminder(null),
          isFalse,
        );
      });
    });
  });
}
