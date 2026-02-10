import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_services.dart';
import 'package:jellomark/features/usage_history/domain/entities/usage_history.dart';
import 'package:jellomark/features/usage_history/domain/usecases/get_usage_history_usecase.dart';
import 'package:jellomark/features/usage_history/presentation/pages/usage_history_page.dart';
import 'package:jellomark/features/usage_history/presentation/providers/usage_history_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUsageHistoryUseCase extends Mock
    implements GetUsageHistoryUseCase {}

class MockGetShopServices extends Mock implements GetShopServices {}

void main() {
  late MockGetUsageHistoryUseCase mockGetUsageHistory;
  late MockGetShopServices mockGetShopServices;

  setUp(() {
    mockGetUsageHistory = MockGetUsageHistoryUseCase();
    mockGetShopServices = MockGetShopServices();
  });

  final tUsageHistory = UsageHistory(
    id: 'uh-1',
    memberId: 'member-1',
    shopId: 'shop-1',
    reservationId: 'reservation-1',
    shopName: '젤로네일',
    treatmentName: '젤네일',
    treatmentPrice: 30000,
    treatmentDuration: 60,
    completedAt: DateTime(2026, 1, 15, 14, 0),
    createdAt: DateTime(2026, 1, 15, 14, 0),
  );

  Widget createPage() {
    return ProviderScope(
      overrides: [
        getUsageHistoryUseCaseProvider.overrideWithValue(mockGetUsageHistory),
        getShopServicesUseCaseProvider.overrideWithValue(mockGetShopServices),
      ],
      child: const MaterialApp(
        home: UsageHistoryPage(),
      ),
    );
  }

  group('UsageHistoryPage', () {
    testWidgets('should display app bar title', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('이용기록'), findsOneWidget);
    });

    testWidgets('should show loading indicator during load', (tester) async {
      when(() => mockGetUsageHistory()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Right(<UsageHistory>[]),
        ),
      );

      await tester.pumpWidget(createPage());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no history', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => const Right(<UsageHistory>[]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('이용기록이 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('should display error state with retry', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('서버 오류'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should retry on retry button tap', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => const Left(ServerFailure('서버 오류')));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory]));

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(find.text('젤로네일'), findsOneWidget);
    });

    testWidgets('should display usage history list', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('젤로네일'), findsOneWidget);
      expect(find.text('젤네일'), findsOneWidget);
      expect(find.text('또 예약하기'), findsOneWidget);
    });

    testWidgets('should show snackbar when rebook fails', (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory]));
      when(() => mockGetShopServices(shopId: 'shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('네트워크 오류')));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('또 예약하기'));
      await tester.pumpAndSettle();

      expect(find.text('네트워크 오류'), findsOneWidget);
    });

    testWidgets('should show snackbar when no treatments found',
        (tester) async {
      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory]));
      when(() => mockGetShopServices(shopId: 'shop-1'))
          .thenAnswer((_) async => const Right(<ServiceMenu>[]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('또 예약하기'));
      await tester.pumpAndSettle();

      expect(find.text('해당 샵의 시술 정보를 찾을 수 없습니다'), findsOneWidget);
    });

    testWidgets('should display multiple history items', (tester) async {
      final tUsageHistory2 = UsageHistory(
        id: 'uh-2',
        memberId: 'member-1',
        shopId: 'shop-2',
        reservationId: 'reservation-2',
        shopName: '뷰티헤어',
        treatmentName: '커트',
        treatmentPrice: 15000,
        treatmentDuration: 30,
        completedAt: DateTime(2026, 1, 10, 10, 0),
        createdAt: DateTime(2026, 1, 10, 10, 0),
      );

      when(() => mockGetUsageHistory())
          .thenAnswer((_) async => Right([tUsageHistory, tUsageHistory2]));

      await tester.pumpWidget(createPage());
      await tester.pumpAndSettle();

      expect(find.text('젤로네일'), findsOneWidget);
      expect(find.text('뷰티헤어'), findsOneWidget);
      expect(find.text('또 예약하기'), findsNWidgets(2));
    });
  });
}
