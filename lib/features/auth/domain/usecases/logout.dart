import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, void>> call() async {
    return await _authRepository.logout();
  }
}
