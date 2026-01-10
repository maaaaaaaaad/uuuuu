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
      final kakaoAccessToken = await _kakaoAuthService.loginWithKakao();

      return await _authRepository.loginWithKakao(kakaoAccessToken);
    } catch (e) {
      return Left(KakaoLoginFailure(e.toString()));
    }
  }
}
