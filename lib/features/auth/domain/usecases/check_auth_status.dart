import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, Member>> call() async {
    final tokens = await _authRepository.getStoredTokens();
    if (tokens == null) {
      return const Left(NoTokenFailure());
    }

    final result = await _authRepository.getCurrentMember();
    if (result.isLeft()) {
      final failure = result.fold(
        (f) => f,
        (_) => const AuthFailure('unexpected'),
      );
      if (failure is AuthFailure) {
        await _authRepository.clearStoredTokens();
      }
    }
    return result;
  }
}
