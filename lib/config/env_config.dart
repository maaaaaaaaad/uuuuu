class EnvConfig {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.219.100:8080',
  );

  static const String kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );

  static const String naverMapClientId = String.fromEnvironment(
    'NAVER_MAP_CLIENT_ID',
    defaultValue: '5yi4ydr7p1',
  );

  static const String naverApiBaseUrl = String.fromEnvironment(
    'NAVER_API_BASE_URL',
    defaultValue: 'https://naveropenapi.apigw.ntruss.com',
  );

  static const String naverClientId = String.fromEnvironment(
    'NAVER_CLIENT_ID',
    defaultValue: '5yi4ydr7p1',
  );

  static const String naverClientSecret = String.fromEnvironment(
    'NAVER_CLIENT_SECRET',
    defaultValue: 'n2dZBuBFQjHCnr5lfoeaKflSN6x46Ix7sofBqIfD',
  );

  static bool get isDebug => env == 'dev';
  static bool get isProduction => env == 'prod';
}
