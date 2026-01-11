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
