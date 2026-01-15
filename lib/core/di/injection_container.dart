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
import 'package:jellomark/features/beautishop/data/datasources/beauty_shop_remote_datasource.dart';
import 'package:jellomark/features/beautishop/data/repositories/beauty_shop_repository_impl.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_filtered_shops_usecase.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_reviews.dart';
import 'package:jellomark/features/category/data/datasources/category_remote_datasource.dart';
import 'package:jellomark/features/category/data/repositories/category_repository_impl.dart';
import 'package:jellomark/features/category/domain/repositories/category_repository.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/review/data/datasources/review_remote_datasource.dart';
import 'package:jellomark/features/review/data/repositories/review_repository_impl.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/create_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/delete_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/get_shop_reviews_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/update_review_usecase.dart';
import 'package:jellomark/features/search/data/datasources/search_local_datasource.dart';
import 'package:jellomark/features/search/data/repositories/search_repository_impl.dart';
import 'package:jellomark/features/search/domain/repositories/search_repository.dart';
import 'package:jellomark/features/search/domain/usecases/manage_search_history_usecase.dart';
import 'package:jellomark/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:jellomark/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:jellomark/features/treatment/domain/usecases/get_shop_treatments_usecase.dart';

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
      kakaoAuthService: sl<KakaoAuthService>(),
    ),
  );

  sl.registerLazySingleton<GetCurrentMember>(
    () => GetCurrentMember(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<BeautyShopRemoteDataSource>(
    () => BeautyShopRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<BeautyShopRepository>(
    () => BeautyShopRepositoryImpl(
      remoteDataSource: sl<BeautyShopRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetFilteredShopsUseCase>(
    () => GetFilteredShopsUseCase(repository: sl<BeautyShopRepository>()),
  );

  sl.registerLazySingleton<GetShopReviews>(
    () => GetShopReviews(repository: sl<BeautyShopRepository>()),
  );

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: sl<CategoryRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(repository: sl<CategoryRepository>()),
  );

  sl.registerLazySingleton<TreatmentRemoteDataSource>(
    () => TreatmentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<TreatmentRepository>(
    () => TreatmentRepositoryImpl(
      remoteDataSource: sl<TreatmentRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetShopTreatmentsUseCase>(
    () => GetShopTreatmentsUseCase(repository: sl<TreatmentRepository>()),
  );

  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl<ReviewRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetShopReviewsUseCase>(
    () => GetShopReviewsUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<CreateReviewUseCase>(
    () => CreateReviewUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<UpdateReviewUseCase>(
    () => UpdateReviewUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<DeleteReviewUseCase>(
    () => DeleteReviewUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(localDataSource: sl<SearchLocalDataSource>()),
  );

  sl.registerLazySingleton<ManageSearchHistoryUseCase>(
    () => ManageSearchHistoryUseCase(repository: sl<SearchRepository>()),
  );

  _initialized = true;
}

void resetForTest() {
  sl.reset();
  _initialized = false;
}
