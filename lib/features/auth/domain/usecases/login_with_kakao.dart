import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class LoginWithKakaoUseCase {
  final AuthRepository _authRepository;

  LoginWithKakaoUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, TokenPair>> call() async {
    return await _authRepository.loginWithKakaoSdk();
  }
}
