import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

class GetCurrentMember {
  final AuthRepository repository;

  GetCurrentMember({required this.repository});

  Future<Either<Failure, Member>> call() async {
    return await repository.getCurrentMember();
  }
}
