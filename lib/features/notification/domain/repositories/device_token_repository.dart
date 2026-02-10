import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';

abstract class DeviceTokenRepository {
  Future<Either<Failure, void>> registerToken(String token, String platform);
  Future<Either<Failure, void>> unregisterToken(String token);
}
