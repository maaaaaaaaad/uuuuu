import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/config/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('home route is /', () {
      expect(AppRoutes.home, equals('/'));
    });

    test('login route is /login', () {
      expect(AppRoutes.login, equals('/login'));
    });

    test('splash route is /splash', () {
      expect(AppRoutes.splash, equals('/splash'));
    });

    test('shopDetail pattern is /shop/:id', () {
      expect(AppRoutes.shopDetail, equals('/shop/:id'));
    });

    test('shopDetailPath generates correct path with id', () {
      expect(AppRoutes.shopDetailPath('123'), equals('/shop/123'));
      expect(AppRoutes.shopDetailPath('shop-abc'), equals('/shop/shop-abc'));
    });
  });
}
