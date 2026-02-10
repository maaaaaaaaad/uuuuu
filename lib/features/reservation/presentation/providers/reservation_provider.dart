import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/create_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';

final createReservationUseCaseProvider =
    Provider<CreateReservationUseCase>((ref) {
  return sl<CreateReservationUseCase>();
});

final getMyReservationsUseCaseProvider =
    Provider<GetMyReservationsUseCase>((ref) {
  return sl<GetMyReservationsUseCase>();
});

final cancelReservationUseCaseProvider =
    Provider<CancelReservationUseCase>((ref) {
  return sl<CancelReservationUseCase>();
});

class MyReservationsState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? error;
  final ReservationStatus? filterStatus;

  const MyReservationsState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  List<Reservation> get filteredReservations => filterStatus == null
      ? reservations
      : reservations.where((r) => r.status == filterStatus).toList();

  MyReservationsState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error,
    ReservationStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return MyReservationsState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

class MyReservationsNotifier extends StateNotifier<MyReservationsState> {
  final Ref _ref;

  MyReservationsNotifier(this._ref) : super(const MyReservationsState());

  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getMyReservationsUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (reservations) {
        state = state.copyWith(
          reservations: reservations,
          isLoading: false,
        );
      },
    );
  }

  void filterByStatus(ReservationStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }

  Future<void> cancelReservation(String id) async {
    final useCase = _ref.read(cancelReservationUseCaseProvider);
    final result = await useCase(id);

    if (result.isLeft()) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (_) {},
      );
    } else {
      await loadReservations();
    }
  }

  Future<void> refresh() async {
    await loadReservations();
  }
}

final myReservationsNotifierProvider = StateNotifierProvider.autoDispose<
    MyReservationsNotifier, MyReservationsState>(
  (ref) => MyReservationsNotifier(ref),
);

class CreateReservationState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const CreateReservationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  CreateReservationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return CreateReservationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

class CreateReservationNotifier extends StateNotifier<CreateReservationState> {
  final Ref _ref;

  CreateReservationNotifier(this._ref)
      : super(const CreateReservationState());

  Future<void> createReservation(CreateReservationParams params) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    final useCase = _ref.read(createReservationUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}

final createReservationNotifierProvider = StateNotifierProvider.autoDispose<
    CreateReservationNotifier, CreateReservationState>(
  (ref) => CreateReservationNotifier(ref),
);
