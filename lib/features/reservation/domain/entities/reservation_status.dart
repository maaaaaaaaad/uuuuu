enum ReservationStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  completed,
  noShow;

  String get label => switch (this) {
        pending => '대기중',
        confirmed => '확정',
        rejected => '거절',
        cancelled => '취소',
        completed => '완료',
        noShow => '노쇼',
      };

  static ReservationStatus fromString(String value) => switch (value) {
        'PENDING' => pending,
        'CONFIRMED' => confirmed,
        'REJECTED' => rejected,
        'CANCELLED' => cancelled,
        'COMPLETED' => completed,
        'NO_SHOW' => noShow,
        _ => throw ArgumentError('Unknown ReservationStatus: $value'),
      };

  bool get isTerminal => switch (this) {
        pending || confirmed => false,
        rejected || cancelled || completed || noShow => true,
      };

  bool get isCancellable => this == pending || this == confirmed;
}
