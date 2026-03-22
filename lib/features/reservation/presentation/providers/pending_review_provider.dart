import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_pending_review_reservations_usecase.dart';

final getPendingReviewReservationsUseCaseProvider =
    Provider<GetPendingReviewReservationsUseCase>((ref) {
  return sl<GetPendingReviewReservationsUseCase>();
});

class PendingReviewState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? error;

  const PendingReviewState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  PendingReviewState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return PendingReviewState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PendingReviewNotifier extends StateNotifier<PendingReviewState> {
  final Ref _ref;

  PendingReviewNotifier(this._ref) : super(const PendingReviewState());

  Future<void> loadPendingReviews() async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(getPendingReviewReservationsUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (reservations) =>
          state = PendingReviewState(reservations: reservations),
    );
  }

  void removeByReservationId(String reservationId) {
    final updated =
        state.reservations.where((r) => r.id != reservationId).toList();
    state = PendingReviewState(reservations: updated);
  }

  Future<void> refresh() async {
    await loadPendingReviews();
  }
}

final pendingReviewNotifierProvider = StateNotifierProvider.autoDispose<
    PendingReviewNotifier, PendingReviewState>(
  (ref) {
    final notifier = PendingReviewNotifier(ref);
    notifier.loadPendingReviews();
    return notifier;
  },
);

final pendingReviewCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(pendingReviewNotifierProvider);
  return state.reservations.length;
});
