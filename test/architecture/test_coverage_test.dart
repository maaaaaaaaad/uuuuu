import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const knownMissingTests = <String>[];

void main() {
  group('Test Coverage Verification', () {
    const mainSrc = 'lib/features';
    const testSrc = 'test/features';

    final domains = [
      'auth',
      'member',
      'beautishop',
      'home',
      'category',
      'review',
      'treatment',
      'search',
    ];

    group('UseCase Test Coverage', () {
      test('every UseCase should have a corresponding unit test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final usecasesDir = Directory('$mainSrc/$domain/domain/usecases');
          if (!usecasesDir.existsSync()) continue;

          final usecaseFiles = usecasesDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('_test.dart'));

          for (final usecaseFile in usecaseFiles) {
            final fileName = usecaseFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File(
              '$testSrc/$domain/domain/usecases/$testFileName',
            );

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing UseCase unit tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });

    group('Repository Implementation Test Coverage', () {
      test('every RepositoryImpl should have a corresponding test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final repoDir = Directory('$mainSrc/$domain/data/repositories');
          if (!repoDir.existsSync()) continue;

          final repoFiles = repoDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('_impl.dart'))
              .where((f) => !_isKnownMissingTest(f.path));

          for (final repoFile in repoFiles) {
            final fileName = repoFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File(
              '$testSrc/$domain/data/repositories/$testFileName',
            );

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing Repository implementation tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });

    group('Entity Test Coverage', () {
      test('every Entity should have a corresponding test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final entitiesDir = Directory('$mainSrc/$domain/domain/entities');
          if (!entitiesDir.existsSync()) continue;

          final entityFiles = entitiesDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('_test.dart'));

          for (final entityFile in entityFiles) {
            final fileName = entityFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File(
              '$testSrc/$domain/domain/entities/$testFileName',
            );

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing Entity unit tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });

    group('DataSource Test Coverage', () {
      test('every DataSource should have a corresponding test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final datasourcesDir = Directory('$mainSrc/$domain/data/datasources');
          if (!datasourcesDir.existsSync()) continue;

          final datasourceFiles = datasourcesDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('_test.dart'));

          for (final datasourceFile in datasourceFiles) {
            final fileName = datasourceFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File(
              '$testSrc/$domain/data/datasources/$testFileName',
            );

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing DataSource tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });

    group('Model Test Coverage', () {
      test('every Model should have a corresponding test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final modelsDir = Directory('$mainSrc/$domain/data/models');
          if (!modelsDir.existsSync()) continue;

          final modelFiles = modelsDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('_test.dart'));

          for (final modelFile in modelFiles) {
            final fileName = modelFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File('$testSrc/$domain/data/models/$testFileName');

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing Model unit tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });

    group('Widget Test Coverage', () {
      test('every Page should have a corresponding test', () {
        final missingTests = <String>[];

        for (final domain in domains) {
          final pagesDir = Directory('$mainSrc/$domain/presentation/pages');
          if (!pagesDir.existsSync()) continue;

          final pageFiles = pagesDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('_test.dart'));

          for (final pageFile in pageFiles) {
            final fileName = pageFile.path.split('/').last;
            final testFileName = fileName.replaceAll('.dart', '_test.dart');
            final testFile = File(
              '$testSrc/$domain/presentation/pages/$testFileName',
            );

            if (!testFile.existsSync()) {
              missingTests.add('$domain: $fileName -> missing $testFileName');
            }
          }
        }

        expect(
          missingTests,
          isEmpty,
          reason:
              'Missing Page widget tests:\n${missingTests.map((t) => '  - $t').join('\n')}',
        );
      });
    });
  });
}

bool _isKnownMissingTest(String filePath) {
  return knownMissingTests.any((v) => filePath.contains(v));
}
