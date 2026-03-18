import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_reservation_usecase.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';

final getReservationUseCaseProvider = Provider<GetReservationUseCase>((ref) {
  return sl<GetReservationUseCase>();
});

class ReservationDetailState {
  final Reservation? reservation;
  final bool isLoading;
  final String? error;

  const ReservationDetailState({
    this.reservation,
    this.isLoading = false,
    this.error,
  });

  ReservationDetailState copyWith({
    Reservation? reservation,
    bool? isLoading,
    String? error,
  }) {
    return ReservationDetailState(
      reservation: reservation ?? this.reservation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReservationDetailNotifier extends StateNotifier<ReservationDetailState> {
  final Ref _ref;
  final String _reservationId;

  ReservationDetailNotifier(this._ref, this._reservationId)
      : super(const ReservationDetailState());

  Future<void> loadReservation() async {
    final myState = _ref.read(myReservationsNotifierProvider);
    final cached = myState.reservations.where((r) => r.id == _reservationId);
    if (cached.isNotEmpty) {
      state = ReservationDetailState(reservation: cached.first);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(getReservationUseCaseProvider);
    final result = await useCase(_reservationId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (reservation) =>
          state = ReservationDetailState(reservation: reservation),
    );
  }
}

final reservationDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<ReservationDetailNotifier, ReservationDetailState, String>(
  (ref, reservationId) {
    final notifier = ReservationDetailNotifier(ref, reservationId);
    notifier.loadReservation();
    return notifier;
  },
);
