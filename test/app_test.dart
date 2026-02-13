import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/app.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/auth/domain/usecases/check_auth_status.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}

void main() {
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;

  setUp(() {
    resetForTest();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    when(() => mockCheckAuthStatusUseCase()).thenAnswer(
      (_) async => const Left(NoTokenFailure()),
    );
  });

  tearDown(() {
    resetForTest();
  });

  group('JelloMarkApp', () {
    testWidgets('should force light mode only (no dark theme)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              checkAuthStatusUseCaseProvider.overrideWithValue(mockCheckAuthStatusUseCase),
            ],
            child: const JelloMarkApp(),
          ),
        );

        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

        expect(materialApp.darkTheme, isNull);
        expect(materialApp.themeMode, ThemeMode.light);
      });
    });

    testWidgets('should have MaterialApp with correct title', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              checkAuthStatusUseCaseProvider.overrideWithValue(mockCheckAuthStatusUseCase),
            ],
            child: const JelloMarkApp(),
          ),
        );

        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

        expect(materialApp.title, '젤로마크');
        expect(materialApp.debugShowCheckedModeBanner, false);
      });
    });
  });
}
