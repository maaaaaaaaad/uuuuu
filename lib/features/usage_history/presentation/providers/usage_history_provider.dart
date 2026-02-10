import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/usecases/get_usage_history_usecase.dart';

final getUsageHistoryUseCaseProvider =
    Provider<GetUsageHistoryUseCase>((ref) {
  return sl<GetUsageHistoryUseCase>();
});

class UsageHistoryState {
  final List<UsageHistory> histories;
  final bool isLoading;
  final String? error;

  const UsageHistoryState({
    this.histories = const [],
    this.isLoading = false,
    this.error,
  });

  UsageHistoryState copyWith({
    List<UsageHistory>? histories,
    bool? isLoading,
    String? error,
  }) {
    return UsageHistoryState(
      histories: histories ?? this.histories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UsageHistoryNotifier extends StateNotifier<UsageHistoryState> {
  final Ref _ref;

  UsageHistoryNotifier(this._ref) : super(const UsageHistoryState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = _ref.read(getUsageHistoryUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (histories) {
        state = state.copyWith(histories: histories, isLoading: false);
      },
    );
  }

  Future<void> refresh() async {
    await load();
  }
}

final usageHistoryNotifierProvider =
    StateNotifierProvider.autoDispose<UsageHistoryNotifier, UsageHistoryState>(
  (ref) => UsageHistoryNotifier(ref),
);
