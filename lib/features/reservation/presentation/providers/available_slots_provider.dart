import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slots_result.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_dates_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_slots_usecase.dart';

final getAvailableDatesUseCaseProvider =
    Provider<GetAvailableDatesUseCase>((ref) {
  return sl<GetAvailableDatesUseCase>();
});

final getAvailableSlotsUseCaseProvider =
    Provider<GetAvailableSlotsUseCase>((ref) {
  return sl<GetAvailableSlotsUseCase>();
});

class AvailableDatesState {
  final List<String> dates;
  final bool isLoading;
  final String? error;

  const AvailableDatesState({
    this.dates = const [],
    this.isLoading = false,
    this.error,
  });

  AvailableDatesState copyWith({
    List<String>? dates,
    bool? isLoading,
    String? error,
  }) {
    return AvailableDatesState(
      dates: dates ?? this.dates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AvailableDatesNotifier extends StateNotifier<AvailableDatesState> {
  final Ref _ref;

  AvailableDatesNotifier(this._ref) : super(const AvailableDatesState());

  Future<void> loadDates(
      String shopId, String treatmentId, String yearMonth) async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getAvailableDatesUseCaseProvider);
    final result = await useCase(shopId, treatmentId, yearMonth);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (dates) {
        state = state.copyWith(dates: dates, isLoading: false);
      },
    );
  }

  void reset() {
    state = const AvailableDatesState();
  }
}

final availableDatesNotifierProvider = StateNotifierProvider.autoDispose<
    AvailableDatesNotifier, AvailableDatesState>(
  (ref) => AvailableDatesNotifier(ref),
);

class AvailableSlotsState {
  final List<AvailableSlot> slots;
  final String? openTime;
  final String? closeTime;
  final bool isLoading;
  final String? error;

  const AvailableSlotsState({
    this.slots = const [],
    this.openTime,
    this.closeTime,
    this.isLoading = false,
    this.error,
  });

  AvailableSlotsState copyWith({
    List<AvailableSlot>? slots,
    String? openTime,
    String? closeTime,
    bool? isLoading,
    String? error,
  }) {
    return AvailableSlotsState(
      slots: slots ?? this.slots,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AvailableSlotsNotifier extends StateNotifier<AvailableSlotsState> {
  final Ref _ref;

  AvailableSlotsNotifier(this._ref) : super(const AvailableSlotsState());

  Future<void> loadSlots(
      String shopId, String treatmentId, String date) async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getAvailableSlotsUseCaseProvider);
    final result = await useCase(shopId, treatmentId, date);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (AvailableSlotsResult slotsResult) {
        state = state.copyWith(
          slots: slotsResult.slots,
          openTime: slotsResult.openTime,
          closeTime: slotsResult.closeTime,
          isLoading: false,
        );
      },
    );
  }

  void reset() {
    state = const AvailableSlotsState();
  }
}

final availableSlotsNotifierProvider = StateNotifierProvider.autoDispose<
    AvailableSlotsNotifier, AvailableSlotsState>(
  (ref) => AvailableSlotsNotifier(ref),
);
