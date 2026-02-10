import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';

class CurrentReservationState {
  final Reservation? todayReservation;
  final Reservation? upcomingReservation;
  final bool isLoading;
  final String? error;

  const CurrentReservationState({
    this.todayReservation,
    this.upcomingReservation,
    this.isLoading = false,
    this.error,
  });

  CurrentReservationState copyWith({
    Reservation? todayReservation,
    Reservation? upcomingReservation,
    bool? isLoading,
    String? error,
    bool clearToday = false,
    bool clearUpcoming = false,
  }) {
    return CurrentReservationState(
      todayReservation:
          clearToday ? null : (todayReservation ?? this.todayReservation),
      upcomingReservation:
          clearUpcoming ? null : (upcomingReservation ?? this.upcomingReservation),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CurrentReservationNotifier extends StateNotifier<CurrentReservationState> {
  final Ref _ref;

  CurrentReservationNotifier(this._ref)
      : super(const CurrentReservationState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getMyReservationsUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) {
        state = const CurrentReservationState(error: null).copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (reservations) {
        final confirmed = reservations
            .where((r) => r.status == ReservationStatus.confirmed)
            .toList();

        final todayStr = _todayString();
        final now = DateTime.now();

        final todayConfirmed = confirmed.where((r) {
          if (r.reservationDate != todayStr) return false;
          final endParts = r.endTime.split(':');
          if (endParts.length != 2) return true;
          final endHour = int.tryParse(endParts[0]) ?? 23;
          final endMinute = int.tryParse(endParts[1]) ?? 59;
          final endDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            endHour,
            endMinute,
          );
          return now.isBefore(endDateTime);
        }).toList();

        final upcomingConfirmed = confirmed
            .where((r) => r.reservationDate.compareTo(todayStr) > 0)
            .toList()
          ..sort((a, b) => a.reservationDate.compareTo(b.reservationDate));

        state = CurrentReservationState(
          todayReservation:
              todayConfirmed.isNotEmpty ? todayConfirmed.first : null,
          upcomingReservation:
              upcomingConfirmed.isNotEmpty ? upcomingConfirmed.first : null,
          isLoading: false,
        );
      },
    );
  }

  String _todayString() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final currentReservationNotifierProvider = StateNotifierProvider.autoDispose<
    CurrentReservationNotifier, CurrentReservationState>(
  (ref) => CurrentReservationNotifier(ref),
);
