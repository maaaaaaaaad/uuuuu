import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should be instantiable with message', () {
      final failure = ServerFailure('서버 오류');
      expect(failure.message, '서버 오류');
    });

    test('CacheFailure should be instantiable with message', () {
      final failure = CacheFailure('캐시 오류');
      expect(failure.message, '캐시 오류');
    });

    test('NetworkFailure should be instantiable with message', () {
      final failure = NetworkFailure('네트워크 오류');
      expect(failure.message, '네트워크 오류');
    });

    test('AuthFailure should be instantiable with message', () {
      final failure = AuthFailure('인증 오류');
      expect(failure.message, '인증 오류');
    });
  });
}
