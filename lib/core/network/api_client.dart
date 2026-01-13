import 'package:dio/dio.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required String baseUrl, AuthInterceptor? authInterceptor})
    : dio = Dio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers['Content-Type'] = 'application/json';

    if (authInterceptor != null) {
      dio.interceptors.add(authInterceptor);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return dio.delete<T>(path);
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return dio.patch<T>(path, data: data);
  }
}
