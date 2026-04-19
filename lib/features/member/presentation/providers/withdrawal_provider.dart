import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/usecases/withdraw_member.dart';

enum WithdrawalStatus { initial, submitting, success, error }

class WithdrawalState {
  final int step;
  final String? selectedReason;
  final List<bool> agreements;
  final String confirmText;
  final WithdrawalStatus status;
  final String? errorMessage;

  const WithdrawalState({
    this.step = 0,
    this.selectedReason,
    this.agreements = const [false, false, false, false],
    this.confirmText = '',
    this.status = WithdrawalStatus.initial,
    this.errorMessage,
  });

  bool get allAgreed => agreements.every((e) => e);
  bool get confirmTextValid => confirmText.trim() == '회원탈퇴에 동의합니다';

  WithdrawalState copyWith({
    int? step,
    String? selectedReason,
    List<bool>? agreements,
    String? confirmText,
    WithdrawalStatus? status,
    String? errorMessage,
    bool clearReason = false,
  }) {
    return WithdrawalState(
      step: step ?? this.step,
      selectedReason:
          clearReason ? null : (selectedReason ?? this.selectedReason),
      agreements: agreements ?? this.agreements,
      confirmText: confirmText ?? this.confirmText,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class WithdrawalNotifier extends StateNotifier<WithdrawalState> {
  final WithdrawMember _withdrawMember;

  WithdrawalNotifier(this._withdrawMember) : super(const WithdrawalState());

  void goToStep(int step) {
    state = state.copyWith(step: step);
  }

  void next() {
    state = state.copyWith(step: state.step + 1);
  }

  void previous() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void selectReason(String reason) {
    state = state.copyWith(selectedReason: reason);
  }

  void toggleAgreement(int index) {
    final newAgreements = List<bool>.from(state.agreements);
    newAgreements[index] = !newAgreements[index];
    state = state.copyWith(agreements: newAgreements);
  }

  void updateConfirmText(String text) {
    state = state.copyWith(confirmText: text);
  }

  Future<bool> submit() async {
    if (state.selectedReason == null) return false;
    state = state.copyWith(
      status: WithdrawalStatus.submitting,
      errorMessage: null,
    );
    final result = await _withdrawMember(state.selectedReason!);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: WithdrawalStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: WithdrawalStatus.success);
        return true;
      },
    );
  }
}

final withdrawMemberUseCaseProvider = Provider<WithdrawMember>((ref) {
  return WithdrawMember(repository: sl<AuthRepository>());
});

final withdrawalProvider =
    StateNotifierProvider.autoDispose<WithdrawalNotifier, WithdrawalState>((
      ref,
    ) {
      return WithdrawalNotifier(ref.watch(withdrawMemberUseCaseProvider));
    });
