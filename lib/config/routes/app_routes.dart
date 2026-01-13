class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String splash = '/splash';
  static const String shopDetail = '/shop/:id';

  static String shopDetailPath(String shopId) => '/shop/$shopId';
}
