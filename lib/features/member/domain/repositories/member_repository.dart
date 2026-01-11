import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/member/domain/entities/member.dart';

abstract class MemberRepository {
  Future<Either<Failure, Member>> updateProfile({required String nickname});
}
