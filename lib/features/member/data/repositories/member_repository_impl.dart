import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  @override
  Future<Either<Failure, Member>> updateProfile({
    required String nickname,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(
      Member(id: '1', nickname: nickname, email: 'user@jellomark.com'),
    );
  }
}
