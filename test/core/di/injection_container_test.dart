import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:jellomark/core/di/injection_container.dart' as di;
import 'package:jellomark/core/network/auth_interceptor.dart';

abstract class TestRepository {
  String getData();
}

class TestRepositoryImpl implements TestRepository {
  @override
  String getData() => 'test_data';
}

void main() {
  group('InjectionContainer', () {
    setUp(() {
      di.sl.reset();
      di.resetForTest();
    });

    tearDown(() {
      di.sl.reset();
    });

    test('should initialize without errors', () async {
      await di.initDependencies();

      expect(di.sl.isRegistered<GetIt>(), false);
    });

    test('should be callable multiple times without errors', () async {
      await di.initDependencies();
      await di.initDependencies();

      expect(true, isTrue);
    });

    group('Service Locator Pattern', () {
      test('should register and resolve singleton', () {
        di.sl.registerSingleton<TestRepository>(TestRepositoryImpl());

        final resolved = di.sl<TestRepository>();

        expect(resolved, isA<TestRepositoryImpl>());
        expect(resolved.getData(), 'test_data');
      });

      test('should return same instance for singleton', () {
        di.sl.registerSingleton<TestRepository>(TestRepositoryImpl());

        final first = di.sl<TestRepository>();
        final second = di.sl<TestRepository>();

        expect(identical(first, second), isTrue);
      });

      test('should register and resolve lazy singleton', () {
        di.sl.registerLazySingleton<TestRepository>(() => TestRepositoryImpl());

        final resolved = di.sl<TestRepository>();

        expect(resolved, isA<TestRepositoryImpl>());
      });

      test('should register and resolve factory', () {
        di.sl.registerFactory<TestRepository>(() => TestRepositoryImpl());

        final first = di.sl<TestRepository>();
        final second = di.sl<TestRepository>();

        expect(identical(first, second), isFalse);
      });
    });

    group('Auth Dependencies', () {
      test('should register TokenProvider', () async {
        await di.initDependencies();

        expect(di.sl.isRegistered<TokenProvider>(), isTrue);
      });

      test('should register AuthInterceptor', () async {
        await di.initDependencies();

        expect(di.sl.isRegistered<AuthInterceptor>(), isTrue);
      });
    });
  });
}
