import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/core/network/api_error_handler.dart';

void main() {
  group('ApiErrorHandler', () {
    test('should return NetworkFailure for connection timeout', () {
      final e = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<NetworkFailure>());
      expect(result.message, '인터넷 연결이 느립니다. 잠시 후 다시 시도해주세요');
    });

    test('should return NetworkFailure for connection error', () {
      final e = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<NetworkFailure>());
      expect(result.message, '인터넷 연결을 확인해주세요');
    });

    test('should return NetworkFailure for send timeout', () {
      final e = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<NetworkFailure>());
    });

    test('should return NetworkFailure for receive timeout', () {
      final e = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<NetworkFailure>());
    });

    test('should extract error code and return mapped Korean message', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 409,
          data: {'code': 'DUPLICATE_REVIEW', 'detail': 'Review already exists'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<ValidationFailure>());
      expect(result.message, '이미 리뷰를 작성했습니다');
    });

    test('should return AuthFailure for 401 status', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          data: {'code': 'AUTHENTICATION_FAILED', 'detail': 'Auth failed'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<AuthFailure>());
      expect(result.message, '이메일 또는 비밀번호가 올바르지 않습니다');
    });

    test('should return ValidationFailure for 422 status', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 422,
          data: {'code': 'INVALID_SHOP_NAME', 'detail': 'Invalid shop name'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<ValidationFailure>());
      expect(result.message, '올바른 샵 이름을 입력해주세요');
    });

    test('should return ValidationFailure for 409 status', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 409,
          data: {'code': 'DUPLICATE_SHOP_REG_NUM', 'detail': 'Duplicate'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<ValidationFailure>());
      expect(result.message, '이미 등록된 사업자등록번호입니다');
    });

    test('should use fallback message when error code is unknown', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          data: {'code': 'UNKNOWN_CODE'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(
        e,
        fallback: '데이터를 불러올 수 없습니다',
      );

      expect(result, isA<ServerFailure>());
      expect(result.message, '데이터를 불러올 수 없습니다');
    });

    test('should handle non-map response data', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          data: 'Internal Server Error',
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<ServerFailure>());
    });

    test('should handle null response', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<ServerFailure>());
    });

    test('should return KakaoLoginFailure for INVALID_KAKAO_TOKEN code', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          data: {'code': 'INVALID_KAKAO_TOKEN'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<KakaoLoginFailure>());
      expect(result.message, '카카오 로그인에 실패했습니다. 다시 시도해주세요');
    });

    test('should return KakaoLoginFailure for KAKAO_API code', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          data: {'code': 'KAKAO_API'},
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final result = ApiErrorHandler.fromDioException(e);

      expect(result, isA<KakaoLoginFailure>());
      expect(result.message, '카카오 서비스에 일시적인 문제가 발생했습니다');
    });
  });
}
