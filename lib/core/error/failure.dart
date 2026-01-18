abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class KakaoLoginFailure extends Failure {
  const KakaoLoginFailure(super.message);
}

class NoTokenFailure extends Failure {
  const NoTokenFailure() : super('저장된 토큰이 없습니다');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure()
      : super('위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요.');
}

class LocationPermissionDeniedForeverFailure extends Failure {
  const LocationPermissionDeniedForeverFailure()
      : super('위치 권한이 영구적으로 거부되었습니다. 설정 > 젤로마크에서 위치 권한을 허용해주세요.');
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure()
      : super('위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 켜주세요.');
}
