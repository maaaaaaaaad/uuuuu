import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kAllowedShowModalBottomSheet = {
  'lib/shared/widgets/app_bottom_sheet.dart',
};

const _kAllowedShowDialog = {
  'lib/shared/widgets/app_bottom_sheet.dart',
};

void main() {
  group('Safe overlay architecture', () {
    test('lib/ must not call showModalBottomSheet directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)showModalBottomSheet\s*[<(]'),
        allowed: _kAllowedShowModalBottomSheet,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use showAppBottomSheet (lib/shared/widgets/app_bottom_sheet.dart) instead.\n'
            'showAppBottomSheet wraps the sheet with SafeArea(top:false) and viewInsets.bottom '
            'so the content never hides behind the Android navigation/gesture bar or the keyboard.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('lib/ must not call showDialog directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)showDialog\s*[<(]'),
        allowed: _kAllowedShowDialog,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use showAppDialog (lib/shared/widgets/app_bottom_sheet.dart) instead.\n'
            'showAppDialog wraps the dialog body with SafeArea so it never hides behind system UI.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });
  });
}

List<String> _findViolations({
  required RegExp pattern,
  required Set<String> allowed,
}) {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return const [];

  final violations = <String>[];
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final relative = entity.path.replaceAll(r'\', '/');
    if (allowed.contains(relative)) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      if (pattern.hasMatch(line)) {
        violations.add('  $relative:${i + 1}  ${line.trim()}');
      }
    }
  }
  return violations;
}
