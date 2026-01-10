import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class LoginWithKakaoUseCase {
  final KakaoAuthService _kakaoAuthService;
  final AuthRepository _authRepository;

  LoginWithKakaoUseCase({
    required KakaoAuthService kakaoAuthService,
    required AuthRepository authRepository,
  }) : _kakaoAuthService = kakaoAuthService,
       _authRepository = authRepository;

  Future<Either<Failure, TokenPair>> call() async {
    try {
      // 1. 카카오 로그인으로 카카오 액세스 토큰 획득
      final kakaoAccessToken = await _kakaoAuthService.loginWithKakao();

      // 2. 카카오 토큰으로 서버 인증
      return await _authRepository.loginWithKakao(kakaoAccessToken);
    } catch (e) {
      return Left(KakaoLoginFailure(e.toString()));
    }
  }
}
