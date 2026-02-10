import 'package:dartz/dartz.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/notification/domain/repositories/device_token_repository.dart';

class RegisterDeviceTokenUseCase {
  final DeviceTokenRepository _repository;

  RegisterDeviceTokenUseCase({required DeviceTokenRepository repository})
      : _repository = repository;

  Future<Either<Failure, void>> call(String token, String platform) {
    return _repository.registerToken(token, platform);
  }
}
