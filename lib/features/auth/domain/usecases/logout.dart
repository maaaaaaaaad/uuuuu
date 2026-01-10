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
    try {
      await _kakaoAuthService.logout();
    } catch (_) {}

    return await _authRepository.logout();
  }
}
