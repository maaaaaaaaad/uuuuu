import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/error/failure.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:jellomark/features/treatment/data/models/treatment_model.dart';
import 'package:jellomark/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:jellomark/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTreatmentRemoteDataSource extends Mock
    implements TreatmentRemoteDataSource {}

void main() {
  late TreatmentRepository repository;
  late MockTreatmentRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTreatmentRemoteDataSource();
    repository = TreatmentRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final testTreatment = TreatmentModel(
    id: '550e8400-e29b-41d4-a716-446655440000',
    shopId: '660e8400-e29b-41d4-a716-446655440000',
    name: '젤네일 풀세트',
    price: 50000,
    durationMinutes: 90,
    description: '고급 젤네일 풀세트 시술입니다.',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 10),
  );

  group('TreatmentRepositoryImpl', () {
    group('getShopTreatments', () {
      test('returns list of ServiceMenu on success', () async {
        when(() => mockDataSource.getShopTreatments(any()))
            .thenAnswer((_) async => [testTreatment]);

        final result = await repository.getShopTreatments(
          '660e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<Right<Failure, List<ServiceMenu>>>());
        final treatments = (result as Right).value as List<ServiceMenu>;
        expect(treatments.length, equals(1));
        expect(treatments.first.name, equals('젤네일 풀세트'));
      });

      test('returns empty list when no treatments', () async {
        when(() => mockDataSource.getShopTreatments(any()))
            .thenAnswer((_) async => []);

        final result = await repository.getShopTreatments(
          '660e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<Right<Failure, List<ServiceMenu>>>());
        final treatments = (result as Right).value as List<ServiceMenu>;
        expect(treatments, isEmpty);
      });

      test('returns ServerFailure on DioException', () async {
        when(() => mockDataSource.getShopTreatments(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              data: {'error': 'Internal Server Error'},
            ),
          ),
        );

        final result = await repository.getShopTreatments(
          '660e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<Left<Failure, List<ServiceMenu>>>());
        final failure = (result as Left).value as ServerFailure;
        expect(failure.message, contains('Internal Server Error'));
      });
    });

    group('getTreatmentById', () {
      test('returns ServiceMenu on success', () async {
        when(() => mockDataSource.getTreatmentById(any()))
            .thenAnswer((_) async => testTreatment);

        final result = await repository.getTreatmentById(
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(result, isA<Right<Failure, ServiceMenu>>());
        final treatment = (result as Right).value as ServiceMenu;
        expect(treatment.id, equals('550e8400-e29b-41d4-a716-446655440000'));
        expect(treatment.name, equals('젤네일 풀세트'));
      });

      test('returns ServerFailure on 404 DioException', () async {
        when(() => mockDataSource.getTreatmentById(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 404,
              data: {'error': 'Treatment not found'},
            ),
          ),
        );

        final result = await repository.getTreatmentById('non-existent-id');

        expect(result, isA<Left<Failure, ServiceMenu>>());
        final failure = (result as Left).value as ServerFailure;
        expect(failure.message, contains('Treatment not found'));
      });
    });
  });
}
