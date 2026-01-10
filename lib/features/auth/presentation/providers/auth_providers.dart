import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/auth/domain/usecases/login_with_kakao.dart';
import 'package:jellomark/features/auth/domain/usecases/logout.dart';

final loginWithKakaoUseCaseProvider = Provider<LoginWithKakaoUseCase>((ref) {
  return LoginWithKakaoUseCase(
    kakaoAuthService: sl<KakaoAuthService>(),
    authRepository: sl<AuthRepository>(),
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    kakaoAuthService: sl<KakaoAuthService>(),
    authRepository: sl<AuthRepository>(),
  );
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.initial, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithKakaoUseCase _loginWithKakaoUseCase;

  AuthNotifier(this._loginWithKakaoUseCase) : super(const AuthState());

  Future<bool> loginWithKakao() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginWithKakaoUseCase();

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.authenticated);
        return true;
      },
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.watch(loginWithKakaoUseCaseProvider));
});
