import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/entities/token_pair.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class LoginWithAppleUseCase {
  final AuthRepository _authRepository;

  LoginWithAppleUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, TokenPair>> call() async {
    return await _authRepository.loginWithAppleSdk();
  }
}
