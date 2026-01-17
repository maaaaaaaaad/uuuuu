import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const knownViolations = <String>[];

void main() {
  group('Clean Architecture Rules', () {
    final libDir = Directory('lib');
    final featuresDir = Directory('lib/features');

    final domains = [
      'auth',
      'member',
      'beautishop',
      'home',
      'category',
      'review',
      'treatment',
      'search',
      'location',
    ];

    group('Domain Layer Independence', () {
      test('domain layer should not import from data layer', () {
        final violations = <String>[];

        for (final domain in domains) {
          final domainDir = Directory('${featuresDir.path}/$domain/domain');
          if (!domainDir.existsSync()) continue;

          final dartFiles = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !_isKnownViolation(f.path));

          for (final file in dartFiles) {
            final content = file.readAsStringSync();
            final lines = content.split('\n');

            for (var i = 0; i < lines.length; i++) {
              final line = lines[i];
              if (_isImportLine(line) && _importsDataLayer(line, domain)) {
                violations.add('${file.path}:${i + 1} - $line');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Domain layer should not import from data layer:\n${violations.join('\n')}',
        );
      });

      test('domain layer should not import from presentation layer', () {
        final violations = <String>[];

        for (final domain in domains) {
          final domainDir = Directory('${featuresDir.path}/$domain/domain');
          if (!domainDir.existsSync()) continue;

          final dartFiles = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            final content = file.readAsStringSync();
            final lines = content.split('\n');

            for (var i = 0; i < lines.length; i++) {
              final line = lines[i];
              if (_isImportLine(line) &&
                  _importsPresentationLayer(line, domain)) {
                violations.add('${file.path}:${i + 1} - $line');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Domain layer should not import from presentation layer:\n${violations.join('\n')}',
        );
      });
    });

    group('Data Layer Independence', () {
      test('data layer should not import from presentation layer', () {
        final violations = <String>[];

        for (final domain in domains) {
          final dataDir = Directory('${featuresDir.path}/$domain/data');
          if (!dataDir.existsSync()) continue;

          final dartFiles = dataDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            final content = file.readAsStringSync();
            final lines = content.split('\n');

            for (var i = 0; i < lines.length; i++) {
              final line = lines[i];
              if (_isImportLine(line) &&
                  _importsPresentationLayer(line, domain)) {
                violations.add('${file.path}:${i + 1} - $line');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Data layer should not import from presentation layer:\n${violations.join('\n')}',
        );
      });
    });

    group('Core Package Independence', () {
      test(
        'core package should not import from features (except DI container)',
        () {
          final violations = <String>[];

          final coreDir = Directory('${libDir.path}/core');
          if (!coreDir.existsSync()) return;

          final dartFiles = coreDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) => !f.path.contains('injection_container'));

          for (final file in dartFiles) {
            final content = file.readAsStringSync();
            final lines = content.split('\n');

            for (var i = 0; i < lines.length; i++) {
              final line = lines[i];
              if (_isImportLine(line) && _importsFeaturesPackage(line)) {
                violations.add('${file.path}:${i + 1} - $line');
              }
            }
          }

          expect(
            violations,
            isEmpty,
            reason:
                'Core package should not import from features:\n${violations.join('\n')}',
          );
        },
      );
    });

    group('Interface Location Rules', () {
      test('repository interfaces should be in domain/repositories', () {
        final violations = <String>[];

        for (final domain in domains) {
          final domainDir = Directory('${featuresDir.path}/$domain/domain');
          if (!domainDir.existsSync()) continue;

          final dartFiles = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            final fileName = file.path.split('/').last;
            if (fileName.contains('repository') &&
                !file.path.contains('/repositories/')) {
              violations.add(file.path);
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Repository interfaces should be in domain/repositories:\n${violations.join('\n')}',
        );
      });

      test('usecases should be in domain/usecases', () {
        final violations = <String>[];

        for (final domain in domains) {
          final domainDir = Directory('${featuresDir.path}/$domain/domain');
          if (!domainDir.existsSync()) continue;

          final dartFiles = domainDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            final fileName = file.path.split('/').last;
            if (fileName.contains('usecase') &&
                !file.path.contains('/usecases/')) {
              violations.add(file.path);
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'UseCases should be in domain/usecases:\n${violations.join('\n')}',
        );
      });

      test('entities should be in domain/entities', () {
        final violations = <String>[];

        for (final domain in domains) {
          final entitiesDir = Directory(
            '${featuresDir.path}/$domain/domain/entities',
          );
          if (!entitiesDir.existsSync()) continue;

          final dartFiles = entitiesDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'));

          for (final file in dartFiles) {
            if (!file.path.contains('/entities/')) {
              violations.add(file.path);
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Entities should be in domain/entities:\n${violations.join('\n')}',
        );
      });
    });
  });
}

bool _isImportLine(String line) {
  final trimmed = line.trim();
  return trimmed.startsWith('import ') || trimmed.startsWith("import '");
}

bool _importsDataLayer(String line, String currentDomain) {
  return line.contains('/data/') ||
      line.contains("'package:jellomark/features/$currentDomain/data/");
}

bool _importsPresentationLayer(String line, String currentDomain) {
  return line.contains('/presentation/') ||
      line.contains("'package:jellomark/features/$currentDomain/presentation/");
}

bool _importsFeaturesPackage(String line) {
  return line.contains('/features/') ||
      line.contains("'package:jellomark/features/");
}

bool _isKnownViolation(String filePath) {
  return knownViolations.any((v) => filePath.contains(v));
}
