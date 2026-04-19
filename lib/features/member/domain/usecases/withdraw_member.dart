import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';

class WithdrawMember {
  final AuthRepository repository;

  WithdrawMember({required this.repository});

  Future<Either<Failure, void>> call(String reason) async {
    return await repository.withdraw(reason);
  }
}
