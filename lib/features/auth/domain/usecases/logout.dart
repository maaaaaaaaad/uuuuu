import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final KakaoAuthService _kakaoAuthService;
  final AuthRepository _authRepository;

  LogoutUseCase({
    required KakaoAuthService kakaoAuthService,
    required AuthRepository authRepository,
  }) : _kakaoAuthService = kakaoAuthService,
       _authRepository = authRepository;

  Future<Either<Failure, void>> call() async {
    // 카카오 로그아웃 시도 (실패해도 로컬 토큰은 삭제)
    try {
      await _kakaoAuthService.logout();
    } catch (_) {
      // 카카오 로그아웃 실패는 무시
    }

    // 로컬 토큰 삭제
    return await _authRepository.logout();
  }
}
