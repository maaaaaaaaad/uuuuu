import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';

void main() {
  group('ReservationStatus', () {
    group('label', () {
      test('should return correct Korean labels', () {
        expect(ReservationStatus.pending.label, '대기중');
        expect(ReservationStatus.confirmed.label, '확정');
        expect(ReservationStatus.rejected.label, '거절');
        expect(ReservationStatus.cancelled.label, '취소');
        expect(ReservationStatus.completed.label, '완료');
        expect(ReservationStatus.noShow.label, '노쇼');
      });
    });

    group('fromString', () {
      test('should parse valid status strings', () {
        expect(ReservationStatus.fromString('PENDING'), ReservationStatus.pending);
        expect(ReservationStatus.fromString('CONFIRMED'), ReservationStatus.confirmed);
        expect(ReservationStatus.fromString('REJECTED'), ReservationStatus.rejected);
        expect(ReservationStatus.fromString('CANCELLED'), ReservationStatus.cancelled);
        expect(ReservationStatus.fromString('COMPLETED'), ReservationStatus.completed);
        expect(ReservationStatus.fromString('NO_SHOW'), ReservationStatus.noShow);
      });

      test('should throw ArgumentError for unknown status', () {
        expect(
          () => ReservationStatus.fromString('UNKNOWN'),
          throwsArgumentError,
        );
      });
    });

    group('isTerminal', () {
      test('should return false for non-terminal statuses', () {
        expect(ReservationStatus.pending.isTerminal, false);
        expect(ReservationStatus.confirmed.isTerminal, false);
      });

      test('should return true for terminal statuses', () {
        expect(ReservationStatus.rejected.isTerminal, true);
        expect(ReservationStatus.cancelled.isTerminal, true);
        expect(ReservationStatus.completed.isTerminal, true);
        expect(ReservationStatus.noShow.isTerminal, true);
      });
    });

    group('isCancellable', () {
      test('should return true for pending and confirmed', () {
        expect(ReservationStatus.pending.isCancellable, true);
        expect(ReservationStatus.confirmed.isCancellable, true);
      });

      test('should return false for terminal statuses', () {
        expect(ReservationStatus.rejected.isCancellable, false);
        expect(ReservationStatus.cancelled.isCancellable, false);
        expect(ReservationStatus.completed.isCancellable, false);
        expect(ReservationStatus.noShow.isCancellable, false);
      });
    });
  });
}
