import 'package:dio/dio.dart';
import 'package:jellomark/core/error/error_mapper.dart';
import 'package:jellomark/core/error/failure.dart';

class ApiErrorHandler {
  static const _networkMessage = '인터넷 연결을 확인해주세요';
  static const _timeoutMessage = '인터넷 연결이 느립니다. 잠시 후 다시 시도해주세요';
  static const _serverTimeoutMessage = '서버 응답이 지연되고 있습니다';

  static const _kakaoErrorCodes = {'INVALID_KAKAO_TOKEN', 'KAKAO_API'};

  static Failure fromDioException(DioException e, {String? fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(_timeoutMessage);
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(_serverTimeoutMessage);
      case DioExceptionType.connectionError:
        return const NetworkFailure(_networkMessage);
      case DioExceptionType.badResponse:
        return _fromResponse(e, fallback: fallback);
      default:
        return ServerFailure(fallback ?? ErrorMapper.defaultMessage);
    }
  }

  static Failure _fromResponse(DioException e, {String? fallback}) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    String? code;
    if (data is Map<String, dynamic>) {
      code = data['code'] as String?;
    }

    final message = ErrorMapper.toUserMessage(code, fallback: fallback);

    if (code != null && _kakaoErrorCodes.contains(code)) {
      return KakaoLoginFailure(message);
    }

    if (statusCode == 401) {
      return AuthFailure(message);
    }
    if (statusCode == 409 || statusCode == 400 || statusCode == 422) {
      return ValidationFailure(message);
    }
    if (statusCode == 403) {
      return ServerFailure(message);
    }
    return ServerFailure(message);
  }
}
