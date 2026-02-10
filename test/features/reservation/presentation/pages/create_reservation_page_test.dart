import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/domain/usecases/create_reservation_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_dates_usecase.dart';
import 'package:jellomark/features/reservation/domain/usecases/get_available_slots_usecase.dart';
import 'package:jellomark/features/reservation/presentation/pages/create_reservation_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/available_slots_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateReservationUseCase extends Mock
    implements CreateReservationUseCase {}

class MockGetAvailableDatesUseCase extends Mock
    implements GetAvailableDatesUseCase {}

class MockGetAvailableSlotsUseCase extends Mock
    implements GetAvailableSlotsUseCase {}

void main() {
  late MockCreateReservationUseCase mockCreateUseCase;
  late MockGetAvailableDatesUseCase mockDatesUseCase;
  late MockGetAvailableSlotsUseCase mockSlotsUseCase;

  setUp(() {
    mockCreateUseCase = MockCreateReservationUseCase();
    mockDatesUseCase = MockGetAvailableDatesUseCase();
    mockSlotsUseCase = MockGetAvailableSlotsUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const CreateReservationParams(
      shopId: '',
      treatmentId: '',
      reservationDate: '',
      startTime: '',
    ));
  });

  const tTreatments = [
    ServiceMenu(id: 't-1', name: '젤네일', price: 30000, durationMinutes: 60),
    ServiceMenu(id: 't-2', name: '속눈썹', price: 50000, durationMinutes: 90),
  ];

  Widget createPage() {
    return ProviderScope(
      overrides: [
        createReservationUseCaseProvider
            .overrideWithValue(mockCreateUseCase),
        getAvailableDatesUseCaseProvider
            .overrideWithValue(mockDatesUseCase),
        getAvailableSlotsUseCaseProvider
            .overrideWithValue(mockSlotsUseCase),
      ],
      child: const MaterialApp(
        home: CreateReservationPage(
          shopId: 'shop-1',
          treatments: tTreatments,
        ),
      ),
    );
  }

  group('CreateReservationPage', () {
    testWidgets('should display app bar with title', (tester) async {
      await tester.pumpWidget(createPage());

      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect((appBar.title! as Text).data, '예약하기');
    });

    testWidgets('should display treatment dropdown', (tester) async {
      await tester.pumpWidget(createPage());

      expect(find.text('시술 선택'), findsOneWidget);
    });

    testWidgets('should not show calendar before treatment selection',
        (tester) async {
      await tester.pumpWidget(createPage());

      expect(find.text('날짜 선택'), findsNothing);
    });

    testWidgets('should show calendar after treatment selection',
        (tester) async {
      when(() => mockDatesUseCase(any(), any(), any()))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createPage());

      await tester.tap(find.byType(DropdownButtonFormField<ServiceMenu>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('젤네일 - 30,000원').last);
      await tester.pumpAndSettle();

      expect(find.text('날짜 선택'), findsOneWidget);
    });

    testWidgets('should display memo field', (tester) async {
      await tester.pumpWidget(createPage());

      expect(find.text('메모 (선택사항)'), findsOneWidget);
    });

    testWidgets('should display submit button', (tester) async {
      await tester.pumpWidget(createPage());

      expect(find.widgetWithText(ElevatedButton, '예약하기'), findsOneWidget);
    });

    testWidgets('should display treatment options in dropdown',
        (tester) async {
      await tester.pumpWidget(createPage());

      await tester.tap(find.byType(DropdownButtonFormField<ServiceMenu>));
      await tester.pumpAndSettle();

      expect(find.text('젤네일 - 30,000원'), findsWidgets);
      expect(find.text('속눈썹 - 50,000원'), findsWidgets);
    });

    testWidgets('should display memo text field with max length',
        (tester) async {
      await tester.pumpWidget(createPage());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 200);
    });

    testWidgets('submit button should be disabled initially',
        (tester) async {
      await tester.pumpWidget(createPage());

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '예약하기'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
