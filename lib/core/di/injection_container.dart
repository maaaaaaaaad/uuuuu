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
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_services.dart';
import 'package:jellomark/features/category/data/datasources/category_remote_datasource.dart';
import 'package:jellomark/features/category/data/repositories/category_repository_impl.dart';
import 'package:jellomark/features/category/domain/repositories/category_repository.dart';
import 'package:jellomark/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:jellomark/features/location/data/datasources/directions_remote_data_source.dart';
import 'package:jellomark/features/location/data/datasources/location_datasource.dart';
import 'package:jellomark/features/location/data/repositories/directions_repository_impl.dart';
import 'package:jellomark/features/location/data/repositories/location_repository_impl.dart';
import 'package:jellomark/features/location/domain/repositories/directions_repository.dart';
import 'package:jellomark/features/location/domain/repositories/location_repository.dart';
import 'package:jellomark/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:jellomark/features/member/domain/usecases/get_current_member.dart';
import 'package:jellomark/features/review/data/datasources/review_remote_datasource.dart';
import 'package:jellomark/features/review/data/repositories/review_repository_impl.dart';
import 'package:jellomark/features/review/domain/repositories/review_repository.dart';
import 'package:jellomark/features/review/domain/usecases/create_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/delete_review_usecase.dart';
import 'package:jellomark/features/review/domain/usecases/get_my_reviews_usecase.dart';
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
import 'package:jellomark/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:jellomark/features/favorite/data/repositories/favorite_repository_impl.dart';
import 'package:jellomark/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:jellomark/features/favorite/domain/usecases/add_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/remove_favorite_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:jellomark/features/favorite/domain/usecases/check_favorite_usecase.dart';
import 'package:jellomark/features/recent_shops/data/datasources/recent_shops_local_datasource.dart';
import 'package:jellomark/features/recent_shops/data/repositories/recent_shops_repository_impl.dart';
import 'package:jellomark/features/recent_shops/domain/repositories/recent_shops_repository.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/add_recent_shop_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/clear_recent_shops_usecase.dart';
import 'package:jellomark/features/recent_shops/domain/usecases/get_recent_shops_usecase.dart';
import 'package:jellomark/features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'package:jellomark/features/reservation/data/repositories/reservation_repository_impl.dart';
import 'package:jellomark/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:jellomark/features/reservation/domain/usecases/cancel_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/create_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_dates_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_slots_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_my_reservations_usecase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jellomark/core/notification/fcm_service.dart';
import 'package:jellomark/core/notification/local_notification_service.dart';
import 'package:jellomark/core/notification/navigator_key.dart';
import 'package:jellomark/core/notification/notification_handler.dart';
import 'package:jellomark/features/notification/data/datasources/device_token_remote_datasource.dart';
import 'package:jellomark/features/notification/data/repositories/device_token_repository_impl.dart';
import 'package:jellomark/features/notification/domain/repositories/device_token_repository.dart';
import 'package:jellomark/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:jellomark/features/usage_history/data/datasources/usage_history_remote_datasource.dart';
import 'package:jellomark/features/usage_history/data/repositories/usage_history_repository_impl.dart';
import 'package:jellomark/features/usage_history/domain/repositories/usage_history_repository.dart';
import 'package:jellomark/features/usage_history/domain/usecases/get_usage_history_usecase.dart';

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
    () => AuthInterceptor(
      tokenProvider: sl<TokenProvider>(),
      baseUrl: EnvConfig.apiBaseUrl,
    ),
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

  sl.registerLazySingleton<GetShopServices>(
    () => GetShopServices(repository: sl<BeautyShopRepository>()),
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

  sl.registerLazySingleton<GetMyReviewsUseCase>(
    () => GetMyReviewsUseCase(repository: sl<ReviewRepository>()),
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

  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl<LocationDataSource>()),
  );

  sl.registerLazySingleton<GetCurrentLocationUseCase>(
    () => GetCurrentLocationUseCase(sl<LocationRepository>()),
  );

  sl.registerLazySingleton<DirectionsRemoteDataSource>(
    DirectionsRemoteDataSourceImpl.new,
  );

  sl.registerLazySingleton<DirectionsRepository>(
    () => DirectionsRepositoryImpl(
      remoteDataSource: sl<DirectionsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(remoteDataSource: sl<FavoriteRemoteDataSource>()),
  );

  sl.registerLazySingleton<AddFavoriteUseCase>(
    () => AddFavoriteUseCase(sl<FavoriteRepository>()),
  );

  sl.registerLazySingleton<RemoveFavoriteUseCase>(
    () => RemoveFavoriteUseCase(sl<FavoriteRepository>()),
  );

  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(sl<FavoriteRepository>()),
  );

  sl.registerLazySingleton<CheckFavoriteUseCase>(
    () => CheckFavoriteUseCase(sl<FavoriteRepository>()),
  );

  sl.registerLazySingleton<RecentShopsLocalDataSource>(
    () => RecentShopsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<RecentShopsRepository>(
    () => RecentShopsRepositoryImpl(localDataSource: sl<RecentShopsLocalDataSource>()),
  );

  sl.registerLazySingleton<AddRecentShopUseCase>(
    () => AddRecentShopUseCase(sl<RecentShopsRepository>()),
  );

  sl.registerLazySingleton<GetRecentShopsUseCase>(
    () => GetRecentShopsUseCase(sl<RecentShopsRepository>()),
  );

  sl.registerLazySingleton<ClearRecentShopsUseCase>(
    () => ClearRecentShopsUseCase(sl<RecentShopsRepository>()),
  );

  sl.registerLazySingleton<ReservationRemoteDataSource>(
    () => ReservationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(
      remoteDataSource: sl<ReservationRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<CreateReservationUseCase>(
    () => CreateReservationUseCase(repository: sl<ReservationRepository>()),
  );

  sl.registerLazySingleton<GetMyReservationsUseCase>(
    () => GetMyReservationsUseCase(repository: sl<ReservationRepository>()),
  );

  sl.registerLazySingleton<CancelReservationUseCase>(
    () => CancelReservationUseCase(repository: sl<ReservationRepository>()),
  );

  sl.registerLazySingleton<GetAvailableDatesUseCase>(
    () => GetAvailableDatesUseCase(repository: sl<ReservationRepository>()),
  );

  sl.registerLazySingleton<GetAvailableSlotsUseCase>(
    () => GetAvailableSlotsUseCase(repository: sl<ReservationRepository>()),
  );

  sl.registerLazySingleton<UsageHistoryRemoteDataSource>(
    () => UsageHistoryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<UsageHistoryRepository>(
    () => UsageHistoryRepositoryImpl(
      remoteDataSource: sl<UsageHistoryRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetUsageHistoryUseCase>(
    () => GetUsageHistoryUseCase(repository: sl<UsageHistoryRepository>()),
  );

  sl.registerLazySingleton<DeviceTokenRemoteDataSource>(
    () => DeviceTokenRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<DeviceTokenRepository>(
    () => DeviceTokenRepositoryImpl(
      remoteDataSource: sl<DeviceTokenRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<RegisterDeviceTokenUseCase>(
    () => RegisterDeviceTokenUseCase(repository: sl<DeviceTokenRepository>()),
  );

  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(
      onNotificationTap: (payload) {
        sl<NotificationHandler>().handleNotificationResponsePayload(payload);
      },
    ),
  );

  sl.registerLazySingleton<NotificationHandler>(
    () => NotificationHandler(
      navigatorKey: navigatorKey,
      localNotificationService: sl<LocalNotificationService>(),
    ),
  );

  sl.registerLazySingleton<FcmService>(
    () => FcmService(
      messaging: FirebaseMessaging.instance,
      deviceTokenRepository: sl<DeviceTokenRepository>(),
      notificationHandler: sl<NotificationHandler>(),
    ),
  );

  _initialized = true;
}

void resetForTest() {
  sl.reset();
  _initialized = false;
}
