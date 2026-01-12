import 'package:get_it/get_it.dart';
import 'package:jellomark/config/env_config.dart';
import 'package:jellomark/core/network/api_client.dart';
import 'package:jellomark/core/network/auth_interceptor.dart';
import 'package:jellomark/core/storage/secure_token_storage.dart';
import 'package:jellomark/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jellomark/features/auth/data/datasources/kakao_auth_service.dart';
import 'package:jellomark/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jellomark/features/auth/domain/repositories/auth_repository.dart';
import 'package:jellomark/features/member/data/repositories/member_repository_impl.dart';
import 'package:jellomark/features/member/domain/repositories/member_repository.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/member/domain/usecases/update_member_profile.dart';

final sl = GetIt.instance;

bool _initialized = false;

Future<void> initDependencies() async {
  if (_initialized) {
    return;
  }

  sl.registerLazySingleton<SecureStorageWrapper>(
    () => FlutterSecureStorageWrapper(),
  );

  sl.registerLazySingleton<TokenProvider>(
    () => SecureTokenStorage(secureStorage: sl<SecureStorageWrapper>()),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(tokenProvider: sl<TokenProvider>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: EnvConfig.apiBaseUrl,
      authInterceptor: sl<AuthInterceptor>(),
    ),
  );

  sl.registerLazySingleton<KakaoAuthService>(() => KakaoAuthServiceImpl());

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<SecureStorageWrapper>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<MemberRepository>(() => MemberRepositoryImpl());

  sl.registerLazySingleton<GetCurrentMember>(
    () => GetCurrentMember(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<UpdateMemberProfile>(
    () => UpdateMemberProfile(repository: sl<MemberRepository>()),
  );

  _initialized = true;
}

void resetForTest() {
  sl.reset();
  _initialized = false;
}
